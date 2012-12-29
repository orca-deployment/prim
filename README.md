Overview
--------

__Prim__ gives you the power to assign and manage the primary member of any Rails one–to–many or many–to–many assocation. And it's really simple to get started! Let's say we needed to model a User who could have several Languages:

```ruby
class User < ActiveRecord::Base
  has_many :user_languages
  has_many :languages, through: :user_languages

  ...
end
```

```ruby
class UserLanguage < ActiveRecord::Base
  belongs_to :user
  belongs_to :language

  ...
end
```

```ruby
class Language < ActiveRecord::Base
  has_many :user_languages
  has_many :users, through: :user_languages

  ...
end
```

Great! Now let's say we've added a specific set of Languages. Our Users can now have new Language associations by simply creating a record in the `user_languages` mapping table, relating a User and a Language. But what if we want to know which of a User's Languages is their most important? Well, we could add a `sort_order` or `primary` column to the `user_languages` table, but then we'll need to write code to manage it all.

Enter __Prim__.

With __Prim__ we can just add a line of code to the User model...

```ruby
class User < ActiveRecord::Base
  ...

  has_primary :language
end
```

...and run a migration:

```ruby
class AddPrimaryToUserLanguages < ActiveRecord::Migration
  def change
    add_column :user_languages, :primary, :boolean, { default: false }
  end
end
```

And we're done! Now we can set any User's primary language...

```ruby
User.first.primary_language = Language.where( name: "English" )
```

...and retrieve it:

```ruby
User.first.primary_language
=> #<Language id: 5, name: "English" ... >
```

Contributing
------------

Want to contribute? Find a TODO or [Github issue](https://github.com/OrcaHealth/prim/issues) and take care of it! Or suggest a feature or file a bug on the [issues page](https://github.com/OrcaHealth/prim/issues). Just pack up your commits by rebasing them, then submit a pull request!

