# ActsAsRecursiveTree

[![CI Status](https://github.com/1and1/acts_as_recursive_tree/workflows/CI/badge.svg?branch=main)](https://github.com/1and1/acts_as_recursive_tree/actions?query=workflow%3ACI+branch%3Amaster)
[![Gem Version](https://badge.fury.io/rb/acts_as_recursive_tree.svg)](https://badge.fury.io/rb/acts_as_recursive_tree)

Use the power of recursive SQL statements in your Rails application.

When you have tree based data in your application, you always to struggle with retrieving data. There are solutions, but the always come at a price:

  * Nested Set is fast at retrieval, but when inserting you might have to rearrange bounds, which can be very complex
  * Closure_Tree stores additional data in a separate table, which has be kept up to date

Luckily, there is already a SQL standard that makes it very easy to retrieve data in the traditional parent/child relation. Currently this is only supported in sqlite and Postgres. With this it is possible to query complete trees without the need of extra tables or indices.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acts_as_recursive_tree'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_recursive_tree


In your model class add following line:

```ruby
class Node  < ActiveRecord::Base
  recursive_tree
end
```
That's it. This will assume that your model has a column named `parent_id` which will be used for traversal. If your column is something different, then you can specifiy it in the call to `recursive_tree`:

```ruby
recursive_tree parent_key: :some_other_column
```

Some extra special stuff - if your parent relation is also polymorphic, the specify the polymorphic column:

```ruby
recursive_tree parent_type_column: :some_other_type_column
```

## Usage

After you set up a model for usage, there are now several methods you can use.

### Associations

You have access to following associations:

   * `parent` - the parent of this instance
   * `children` - all children (parent_id = self.id)
   * `self_and_siblings` - all node where parent_id = self.parent_id

### Class Methods

  * `roots` - all root elements (parent_id = nil)
  * `self_and_descendants_of(reference)` - the complete tree of `reference` __including__ `reference` in the result
  * `descendants_of(reference)` - the complete tree of `reference` __excluding__ `reference` in the result
  * `leaves_of(reference)` - special case of descendants where only those elements are returned, that do not have any children
  * `self_and_ancestors_of(reference)` - the complete ancestor list of `reference` __including__ `reference` in the result
  * `ancestors_of(reference)` - the complete ancestor list of `reference` __excluding__ `reference` in the result
  * `roots_of(reference)` - special case of ancestors where only those elements are returned, that do not have any parent 

You can pass in following argument types for `reference`, that will be accepted:
  * `integer` - simple integer value

```ruby
    Node.descendants_of(1234)
```

  * `array` - array of integer value

```ruby
    Node.descendants_of([1234, 5678])
```

  * `ActiveRecord::Base` - instance of an AR::Model class

```ruby
    Node.descendants_of(some_node)
```

  * `ActiveRecord::Relation` - an AR::Relation form the same type

```ruby
    Node.descendants_of(Node.where(foo: :bar))
```


### Instance Methods

For nearly all mentioned scopes and associations there is a corresponding instance method:

  * `root` - returns the root element of this node
  * `self_and_descendants` - the complete tree __including__ `self` in the result
  * `descendants` - the complete tree __excluding__ `self` in the result
  * `leaves` - only leaves of this node
  * `self_and_ancestors` - the complete ancestor list __including__ `self` in the result
  * `ancestors` - the complete ancestor list __excluding__ `self` in the result
  
Those methods simply delegate to the corresponding scope and pass `self` as reference.

__Additional methods:__
  * `siblings` - return all elements where parent_id = self.parent_id __excluding__ `self`
  * `self_and_children` - return all children and self as a Relation
  
__Utility methods:__
  * `root?` - returns true if this node is a root node
  * `leaf?` - returns true if this node is a leave node


## Customizing the recursion

All *ancestors* and *descendants* methods/scopes can take an additional block argument. The block receives ans `opts` argument with which you are able to customize the recursion.


__Depth__

Specify a depth condition. Only the elements matching the depth are returned.
Supported operations are:
  * `==` exact match - can be Integer or Range or Array. When specifying a Range this will result in a `depth BETWEEN min AND max` query. 
  * `!=` except - can be Integer or Array
  * `>` greater than - only Integer
  * `>=` greater than or equals - only Integer
  * `<` less than - only Integer
  * `<=` less than or equals - only Integer

```ruby
Node.descendants_of(1){|opts| opts.depth == 3..6 }
node_instance.descendants{ |opts| opts.depth <= 4 }
node_instance.descendants{ |opts| opts.depth != [4, 7] }
```
NOTE: `depth == 1` is the same as `children/parent`
 
__Condition__

Pass in an additional relation. Only those elements are returned where the condition query matches. 

```ruby
Node.descendants_of(1){|opts| opts.condition = Node.where(active: true) }
node_instance.descendants{ |opts| opts.condition = Node.where(active: true) }
```
NOTE: In contrast to depth, which first gathers the complete tree and then discards all non matching results, this will stop the recursive traversal when the relation is not met. Following two lines are completely different when executed: 

```ruby
node_instance.descendants.where(active: true) # => returns the complete tree and filters than out only the active ones
node_instance.descendants{ |opts| opts.condition = Node.where(active: true) } # => stops the recursion when encountering a non active node, which may return less results than the one above
```

__Ordering__
All the *ancestor* methods will order the result depending on the depth of the recursion. Ordering for the *descendants* methods is disabled by default, but can be enabled if needed.

```ruby
Node.descendants_of(1){|opts| opts.ensure_ordering! }
node_instance.descendants{ |opts| opts.ensure_ordering! }
```

NOTE: if there are many descendants this may cause a severe increase in execution time! 

## Single Table Inheritance (STI)

STI works out of the box. Consider following classes: 

```ruby
class Node  < ActiveRecord::Base
  recursive_tree
end

class SubNode  < Node
  
end
```

When calling ClassMethods the results depend on the class on which you call the method:

```ruby
Node.descendants_of(123) # => returns Node and SubNode instances
SubNode.descendants_of(123) # => returns SubNode instances only
```

Instance Methods make no difference of the class from which they are called:

```ruby
sub_node_instance.descendants # => returns Node and SubNode instances
```


## Known Issues

When using PostgreSQL as underlying database system chances are good that you encounter following error message:

`
ActiveRecord::StatementInvalid: PG::ProtocolViolation: ERROR:  bind message supplies 1 parameters, but prepared statement "" requires 2
`

This is a known ActiveRecord issue which should be fixed in Rails 5.2. Alternative 


## Contributing

1. Fork it ( https://github.com/1and1/acts_as_recursive_tree/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
