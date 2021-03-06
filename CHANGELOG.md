### Version 2.2.0
- Rails 6.0 support

### Version 2.1.1
- Enabled subselect query when using depth
- new QueryOption query_strategy for forcing a specific strategy (:join, :subselect)

### Version 2.1.0
- BUGFIX association self_and_siblings not working
- BUGFIX primary_key of model is retrieved on first usage and not on setup
- NEW when no ordering/depth is required, then use subselect instead of joining the temp table

### Version 2.0.2
- fix for condition relation was executed before merging

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
