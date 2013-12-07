EagerDB
=======

EagerDB is a database management layer for preloading queries. Think of it as a
predictive cache warming tool. It listens to your incoming SQL queries and warms
your cache with queries that you are likely to make.

Development Progress
====================

EagerDB is currently in development (Version 0) and not quite ready to release yet.
If you find any issues or would like to collaborate, please email wangjohn@mit.edu
and I'd love to talk!


Getting Started
===============


Manually Specifying Preloads
============================

If you know exactly what is going to be needed by your application, you can manually
specify queries to preload. For example, if you know that whenever the application makes
a certain SQL query, you can tell EagerDB to load another query. For example, say some
user is looking for the apple pies that grandma made:

    SELECT * FROM pies WHERE name = 'apple_pie' AND creator = 'grandma'

With high probability, you know that user is then looking to try to look for the
recipe to that specific applie pie. Let's say you got back a result from your
original query which was something like: 

    { id: 553, name: 'apple_pie', creator: 'grandma', recipe_id: 234 }

Then, you might want to go ahead and warm your database's cache with the following
query:

    SELECT * FROM recipes WHERE id = 234 AND creator = 'grandma'

However, you'd really like this to be more general. You know that whenever a user
is looking for any type of apple pie with any type of creator, then you should
preload the recipe for that apple pie with that creator. You can do just that in EagerDB. 
Just write the following:

    - "SELECT * FROM pies WHERE name = ? AND creator = ?"
        => "SELECT * FROM recipes WHERE id = ? AND creator = ?", match_result.recipe_id, match_bind_value(1)

There are a couple things here to note about syntax, the dash `-` at the beginning
of the first line signifies that you want to match on that statement. It tells
EagerDB that whenever you see the following statement, preload the statements
that come after which are preceded by a hash rocket `=>`.

You can use `match_bind_value(index)` to get the bind value from the matching
statement. Bind values are the values which are replaced by question marks `?`.
So in our example, `match_bind_value(1)` will correspond to the second
bind value (we index by 0) which in our example would be `grandma`.

You can also use `match_result` to use the result from the match query. By specifying
`match_result.recipe_id`, you are getting the `recipe_id` from the result of the
original matched query. Of course, if you try to use columns that don't exist
for a particular result, you'll get an error so make sure to check your schema beforehand!

