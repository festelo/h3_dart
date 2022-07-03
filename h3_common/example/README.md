This library should only be used if you're building some library for H3.  

In this case you can use abstract `H3` class:

```dart
import 'package:h3_common/h3_common.dart';

class SomeH3Implementation implements H3 {
    ...
}

extension SomeH3Extension on H3 {
    ...
}
```