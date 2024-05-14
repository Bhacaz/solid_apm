# solid_apm

Rails engine to manage APM data without using a third party service.

## Description

> [!IMPORTANT]
> Still work in progress.
> It need to be transformed into a Rails engine.

## TODOs

- [ ] Transform to a Rails engine
- [ ] Paginate transactions list
- [ ] Better handle subscribing to ActiveSupport notifications
- [ ] Allow date range transactions index
- [ ] Use [`rack.after_reply`](https://github.blog/2022-04-11-performance-at-github-deferring-stats-with-rack-after_reply/) to creating the record, event using ActiveJob
- [ ] Add methods to add context to the transaction (i.e. `SolidApm.add_context(user_id: 1)`)

## Notes

https://apexcharts.com/javascript-chart-demos/timeline-charts/advanced
