# solid_apm

Rails engine to manage APM data without using a third party service.

<img src="https://github.com/Bhacaz/solid_apm/assets/7858787/b83a4768-dbff-4c1c-8972-4b9db1092c99" width="400px">
<img src="https://github.com/Bhacaz/solid_apm/assets/7858787/87696866-1fb3-46d6-91ae-0137cc7da578" width="400px">

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
