### Version 2.0.1
- fix for parent_type_column applied not properly

### Version 2.0.0
- drop support for rails < 5.0
- support for polymorphic parent relations

### Version 1.1.1
- BUGFIX: not checking presence of relation with _present?_  method - this causes execution of the relation
- added missing != method for depth

### Version 1.1.0
- scopes and method can now be passed a Proc instance for additional modifications of the query
- new option to specify the depth to query

### Version 1.0.1
- BUGFIX: ordering result when querying ancestors

### Version 1.0.0
- inital release using AREL
