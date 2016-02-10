
> http://stackoverflow.com/questions/1454913/regular-expression-to-find-a-string-included-between-two-characters-while-exclud

# Get word between [- and -]

### example 1
```markdown
this is [-awesome-] {+cool but this is cooler+}
```

`(?<=(\[\-))(.*?)(?=(\-\]))` returns `awesome`, which is between `[-` and `-]`

`(?<=(\{\+))(.*?)(?=(\+\}))` returns `coolor`, which is between `{+` and `+}`

### example 2
```markdown
this is [-awesome-] {+cool but this is cooler+}

this is [-awesome-] {+cool 
but this is cooler+}
```

`(?<=(\{\+))([\S\s]*?)(?=(\+\}))` returns both instances of `cool but this is cooler` __(ignoring carriage returns)__

> Pro-tip. This regex is in php. 

## In javascript

```js
var added = /(\{\+)(.*?)(\+\})/gi;
var removed = /(\[\-)(.*?)(\-\])/gi;
```