
## Thank you for your efforts

`h3_dart` consists of several different packages. 

- [geojson2h3](geojson2h3) - utility functions, port of https://github.com/uber/geojson2h3.
- [h3_common](h3_common) - shared code used by `h3_ffi` and `h3_web`.
- [h3_ffi](h3_ffi) - wrapper for the [H3 C library](https://github.com/uber/h3), for DartVM only.
- [h3_web](h3_web) - wrapper for the [H3 JS library](https://github.com/uber/h3-js), for Web only.
- [h3_dart](h3_dart) - a combination of `h3_ffi` and `h3_web` that works both in Dart VM and Web.
- [h3_flutter](h3_flutter) - similar to `h3_dart`, but works only in Flutter applications. It links the C library automatically, making it more convenient to use than `h3_dart`.

Please read the `README.md` file and the **"For contributors"** section of each individual package.