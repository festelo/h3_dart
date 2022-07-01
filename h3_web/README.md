## H3 Web

This package provides implementation of H3 abstraction from `package:h3` through bindings to Ubers's [h3-js](https://github.com/uber/h3-js) library written on JS.

Bindings are generated using `dart_js_facade_gen` tool, to regenerate them run `npm run generate` (Node.js should be installed)

### Installation

This library is built on top of `h3-js`, you have to import it.  
Add next line to your `index.html`:
```html
    <script defer src="https://unpkg.com/h3-js"></script>
```
**Note, `main.dart.js` import must go after this line**