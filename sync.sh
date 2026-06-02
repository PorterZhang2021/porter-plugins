#!/usr/bin/env bash
set -euo pipefail

# AI Workflow Plugins 跨平台同步工具
# 支持从 kimi/codex/claude 导入配置到当前仓库

SCRIPT_NAME="$(basename "$0")"
VERSION="1.0.0"

# 获取工具默认路径
get_tool_path() {
    case "$1" in
        kimi) echo "$HOME/.kimi" ;;
        codex) echo "$HOME/.codex" ;;
        claude) echo "$HOME/.claude" ;;
        *) echo "" ;;
    esac
}

# 获取工具描述
get_tool_desc() {
    case "$1" in
        kimi) echo "Kimi CLI 配置" ;;
        codex) echo "Codex CLI 配置" ;;
        claude) echo "Claude Code 配置" ;;
        *) echo "" ;;
    esac
}

# 获取同步目标根目录
get_dest_root() {
    case "$1" in
        codex) echo "./plugins/porter-codex-plugin" ;;
        claude) echo "./plugins/porter-claude-plugin" ;;
        kimi) echo "." ;;
        *) echo "." ;;
    esac
}

# 显示帮助
show_help() {
    cat <<EOF
AI Workflow Plugins 跨平台同步工具 v${VERSION}

用法: ${SCRIPT_NAME} [OPTIONS] [TOOL]

AI 工具:
  kimi    - $(get_tool_desc "kimi") (~/.kimi)
  codex   - $(get_tool_desc "codex") (~/.codex)
  claude  - $(get_tool_desc "claude") (~/.claude)

选项:
  -h, --help      显示帮助
  -l, --list      列出支持的 AI 工具
  -p, --path PATH 指定自定义路径
  -n, --dry-run   预览模式

示例:
  ./sync.sh              # 交互式选择
  ./sync.sh --list       # 列出工具
  ./sync.sh kimi         # 从 kimi 导入
  ./sync.sh --dry-run    # 预览
EOF
}

# 列出工具
list_tools() {
    echo "支持的 AI 工具:"
    echo ""
    for tool in kimi codex claude; do
        printf "  %-7s - %s (%s)\n" "$tool" "$(get_tool_desc "$tool")" "$(get_tool_path "$tool")"
    done
}

# 检查路径
check_path() {
    local tool="$1"
    local custom_path="${2:-}"
    
    if [[ -n "$custom_path" ]]; then
        if [[ -d "$custom_path" ]]; then
            echo "$custom_path"
            return 0
        fi
        echo "错误: 路径不存在" >&2
        return 1
    fi
    
    local default_path
    default_path=$(get_tool_path "$tool")
    
    echo "检查默认路径 $default_path ..." >&2
    if [[ -d "$default_path" ]]; then
        echo "✓ 存在" >&2
        echo "$default_path"
        return 0
    else
        echo "✗ 未找到" >&2
        local input_path=""
        while true; do
            read -rp "请输入 $tool 配置目录路径: " input_path
            if [[ -d "$input_path" ]]; then
                echo "✓ 有效" >&2
                echo "$input_path"
                return 0
            fi
            echo "路径不存在，请重新输入" >&2
        done
    fi
}

# 选择工具
select_tools() {
    local selected=""
    while true; do
        read -rp "你的选择: " selected
        
        if [[ "$selected" == "4" ]] || [[ "$selected" == "all" ]]; then
            echo "kimi codex claude"
            return
        fi
        
        local valid=true
        local tools=""
        for num in $selected; do
            case "$num" in
                1) tools="$tools kimi" ;;
                2) tools="$tools codex" ;;
                3) tools="$tools claude" ;;
                *) valid=false; echo "无效选项: $num" >&2 ;;
            esac
        done
        
        if $valid && [[ -n "$tools" ]]; then
            echo "$tools" | xargs
            return
        fi
    done
}

# 扫描目录
scan_directories() {
    local base_path="$1"
    local result=""
    for dir in skills commands agents settings; do
        if [[ -d "$base_path/$dir" ]]; then
            local count
            count=$(find "$base_path/$dir" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l | tr -d ' ')
            result="$result ${dir}:${count}"
        fi
    done
    echo "$result" | xargs
}

# 选择目录
select_directory() {
    local base_path="$1"
    local dir_info
    dir_info=$(scan_directories "$base_path")
    
    if [[ -z "$dir_info" ]]; then
        echo "错误: 未找到可同步的目录" >&2
        return 1
    fi
    
    echo "$base_path 目录内容：" >&2
    echo "" >&2
    
    local i=1
    local dirs=()
    for item in $dir_info; do
        local dir="${item%:*}"
        local count="${item#*:}"
        printf "  %d) %-9s - %d 个项目\n" "$i" "$dir/" "$count" >&2
        dirs+=("$dir")
        ((i++))
    done
    printf "  %d) 全部\n" "$i" >&2
    echo "" >&2
    
    local all_idx=$i
    while true; do
        read -rp "请选择要同步的目录（输入数字）: " selected
        
        if [[ "$selected" == "$all_idx" ]] || [[ "$selected" == "all" ]]; then
            echo "${dirs[*]}"
            return 0
        fi
        
        if [[ "$selected" =~ ^[0-9]+$ ]] && [[ "$selected" -ge 1 ]] && [[ "$selected" -lt "$all_idx" ]]; then
            echo "${dirs[$((selected-1))]}"
            return 0
        fi
        
        echo "无效选项" >&2
    done
}

# 扫描内容
scan_contents() {
    local dir_path="$1"
    find "$dir_path" -maxdepth 1 -mindepth 1 2>/dev/null | sort | xargs -I {} basename "{}" 2>/dev/null | tr '\n' ' ' | sed 's/ $//'
}

# 解析 .syncignore
parse_syncignore() {
    local path="$1"
    local rules=""
    
    [[ ! -f "$path" ]] && return
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -z "$line" ]] && continue
        rules="$rules $line"
    done < "$path"
    
    echo "$rules" | xargs 2>/dev/null || true
}

# 交互式排除
interactive_exclude() {
    local dir_path="$1"
    local items_str
    items_str=$(scan_contents "$dir_path")
    
    [[ -z "$items_str" ]] && return
    
    local items=($items_str)
    local count=${#items[@]}
    
    echo "$dir_path 目录下发现以下内容（共 $count 项）：" >&2
    echo "" >&2
    
    if [[ $count -le 5 ]]; then
        local i=1
        for item in "${items[@]}"; do
            printf "  %d) %s\n" "$i" "$item" >&2
            ((i++))
        done
        echo "" >&2
        echo "是否有需要排除的内容？" >&2
        echo "  1) 是，我要排除某些内容" >&2
        echo "  2) 否，全部同步" >&2
        echo "" >&2
        
        local choice
        while true; do
            read -rp "你的选择: " choice
            case "$choice" in
                1)
                    echo "" >&2
                    read -rp "请输入要排除的编号（多个用空格分隔）: " exclude_nums
                    local excluded=""
                    for num in $exclude_nums; do
                        if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le $count ]]; then
                            excluded="$excluded ${items[$((num-1))]}"
                        fi
                    done
                    if [[ -n "$excluded" ]]; then
                        echo "" >&2
                        echo "已选择排除:" >&2
                        for item in $excluded; do echo "  ✗ $item" >&2; done
                    fi
                    return
                    ;;
                2) return ;;
                *) echo "无效选项" >&2 ;;
            esac
        done
    else
        local display=()
        for item in "${items[@]:0:6}"; do display+=("$item"); done
        echo "  ${display[*]}, ..." >&2
        echo "" >&2
        echo "内容较多，如需排除特定内容，请在目标目录创建 .syncignore 文件。" >&2
        echo "例如 Codex skills: plugins/porter-codex-plugin/skills/.syncignore" >&2
        echo "" >&2
        read -rp "按回车继续..."
    fi
}

# 根据 .syncignore 清理目标目录
cleanup_by_syncignore() {
    local dest_path="$1"
    local syncignore_path="$2"
    local dry_run="$3"
    
    [[ ! -f "$syncignore_path" ]] && return
    [[ ! -d "$dest_path" ]] && return
    
    local cleaned=()
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -z "$line" ]] && continue
        
        # 处理具体路径（如 explain/ 或 explain/TASK.md）
        local target="$dest_path/$line"
        # 移除末尾的 /
        target="${target%/}"
        
        if [[ -e "$target" ]] || [[ -L "$target" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                cleaned+=("$line")
            else
                rm -rf "$target"
                cleaned+=("$line")
            fi
        fi
    done < "$syncignore_path"
    
    if [[ ${#cleaned[@]} -gt 0 ]]; then
        if [[ "$dry_run" == "true" ]]; then
            echo "  [DRY RUN] 将清理以下文件/目录："
        else
            echo "  已清理以下文件/目录："
        fi
        for item in "${cleaned[@]}"; do
            echo "    ✗ $item"
        done
        echo ""
    fi
}

# 执行同步
run_sync() {
    local tool="$1"
    local src_path="$2"
    local dry_run="$3"
    
    local dir_name
    dir_name=$(basename "$src_path")
    local dest_root
    dest_root=$(get_dest_root "$tool")
    local dest_path="$dest_root/$dir_name"
    # 使用当前仓库的 .syncignore 来决定清理和排除
    local syncignore_path="$dest_path/.syncignore"
    
    echo "[$tool/$dir_name]"
    echo "  来源: $src_path/"
    echo "  目标: $dest_path/"
    echo ""
    
    # 先根据当前仓库的 .syncignore 清理目标目录
    if [[ -f "$syncignore_path" ]]; then
        cleanup_by_syncignore "$dest_path" "$syncignore_path" "$dry_run"
    fi
    
    # 构建排除参数（使用当前仓库的 .syncignore）
    local exclude_args="--exclude='.syncignore'"
    if [[ -f "$syncignore_path" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" ]] && continue
            [[ "$line" =~ ^# ]] && continue
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [[ -z "$line" ]] && continue
            exclude_args="$exclude_args --exclude='$line'"
        done < "$syncignore_path"
    fi
    
    # 创建目标目录
    mkdir -p "$dest_path"
    
    if [[ "$dry_run" == "true" ]]; then
        echo "  [DRY RUN] rsync -av $exclude_args ..."
        echo ""
        return
    fi
    
    # 执行 rsync
    if eval rsync -av $exclude_args "$src_path/" "$dest_path/" 2>&1 | grep -E "(sending|sent|total|files|\.md|\.json)" | tail -30; then
        echo ""
        echo "  ✓ 同步完成: $tool/$dir_name"
    else
        echo ""
        echo "  ✗ 同步失败: $tool/$dir_name"
    fi
    echo ""
}

# 主函数
main() {
    local dry_run="false"
    local custom_path=""
    local tool_args=()
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help; exit 0 ;;
            -l|--list) list_tools; exit 0 ;;
            -p|--path) custom_path="$2"; shift 2 ;;
            -n|--dry-run) dry_run="true"; shift ;;
            kimi|codex|claude|all) tool_args+=("$1"); shift ;;
            *) shift ;;
        esac
    done
    
    echo "AI Workflow Plugins 跨平台同步工具"
    echo "================================"
    echo ""
    
    # 确定工具
    local tools=""
    if [[ ${#tool_args[@]} -eq 0 ]]; then
        echo "请选择要同步的 AI 工具（输入数字，多个用空格分隔）："
        echo ""
        echo "  1) kimi   - $(get_tool_desc "kimi") (~/.kimi)"
        echo "  2) codex  - $(get_tool_desc "codex") (~/.codex)"
        echo "  3) claude - $(get_tool_desc "claude") (~/.claude)"
        echo "  4) 全部"
        echo ""
        tools=$(select_tools)
        echo ""
    else
        [[ "${tool_args[0]}" == "all" ]] && tools="kimi codex claude" || tools="${tool_args[0]}"
    fi
    
    echo "已选择: $tools"
    echo ""
    
    # 收集任务
    declare -a SYNC_TASKS
    
    for tool in $tools; do
        echo "[$tool]"
        local tool_path
        if ! tool_path=$(check_path "$tool" "$custom_path"); then
            exit 1
        fi
        echo "路径: $tool_path"
        echo ""
        
        local selected_dir
        selected_dir=$(select_directory "$tool_path")
        echo "已选择目录: $selected_dir"
        echo ""
        
        for dir in $selected_dir; do
            local full_path="$tool_path/$dir"
            local ignore_rules
            ignore_rules=$(parse_syncignore "$full_path/.syncignore")
            
            if [[ -n "$ignore_rules" ]]; then
                echo "发现 .syncignore，以下内容将被排除:"
                for rule in $ignore_rules; do echo "  ✗ $rule"; done
                echo ""
            fi
            
            interactive_exclude "$full_path" >&2
            SYNC_TASKS+=("$tool|$full_path")
            
            echo "------------------------"
            echo "同步: $tool/$dir → 当前仓库/$(get_dest_root "$tool")/$dir/"
            echo "来源: $full_path"
            echo "目标: $(get_dest_root "$tool")/$dir/"
            [[ -n "$ignore_rules" ]] && echo "排除: $ignore_rules"
            echo "------------------------"
            echo ""
        done
        echo ""
    done
    
    [[ ${#SYNC_TASKS[@]} -eq 0 ]] && { echo "没有选择任何同步任务"; exit 0; }
    
    if [[ "$dry_run" == "true" ]]; then
        echo "========================"
        echo "[DRY RUN 模式 - 未实际执行]"
        echo "========================"
        exit 0
    fi
    
    # 执行同步
    echo ""
    echo "开始执行同步..."
    echo "========================"
    echo ""
    
    for task in "${SYNC_TASKS[@]}"; do
        IFS='|' read -r tool src_path <<< "$task"
        run_sync "$tool" "$src_path" "$dry_run"
    done
    
    echo "========================"
    echo "所有同步任务完成!"
    echo "========================"
}

main "$@"
