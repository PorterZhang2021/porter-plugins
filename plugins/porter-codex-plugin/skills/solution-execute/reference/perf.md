# perf — Solution Execute Reference

## Read From TASK.md

- Baseline measurement or collection plan tasks.
- Bottleneck confirmation tasks.
- Optimization implementation tasks.
- Post-optimization verification tasks.

## Execution Order

1. Collect or confirm baseline data.
2. Confirm the bottleneck.
3. Implement the optimization only if the baseline and bottleneck still support it.
4. Measure after the optimization.
5. Compare against baseline.
6. Update `TASK.md`.

## Verification

- Baseline command, input, environment, and result must be recorded when available.
- Optimization must preserve accepted behavior.
- Post-optimization measurement must be compared with baseline.
- If no durable metric is possible, record the limitation and observable evidence.

## TASK.md Update

- Do not mark optimization complete before post-change measurement or recorded limitation.
- Record baseline, comparison result, and any changed bottleneck assumption.

## Stop And Review

Stop and enter review if baseline data contradicts the expected bottleneck, optimization direction becomes stale, or accepted performance criteria need to change.
