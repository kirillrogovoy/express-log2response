# Log2response
Log2response is a tool (express middleware) that provides simple API to send your request-based logs directly into browser console. Its not a complex log utility, so you probably should use it with your main tool like [bunyan] as a transport

# Features
- All request-based logs in your developer's console
- Colored output
- Callbacks that will help you to customize output, e.g. if color depends of content
- Easy to use with another log utility

# Installition
```sh
npm install --save-dev bunyan
```

# Usage
First, execute as a middleware:
```js
app.use(require('express-log2response')(options));
```
You can specify next options. All of these is not required:
<table>
<tr>
<th>Option</th>
<th>Type</th>
<th>Example</th>
</tr>
<tr>
<td>css</td>
<td>string</td>
<td>background: #222; color: lightgreen</td>
</tr>
<tr>
<td colspan=3>Default css that will be used for browser console output. Defaults to example value</td>
</tr>
<tr>
<td>logCallback</td>
<td>function(log)</td>
<td>
<pre>
function(log) {
  if(log.input.level == 'error')
    log.css = 'color: red';
  log.input = log.input.msg;
}
</pre>
</td>
</tr>
<tr>
<td colspan=3>Function that will be called for each log item before sending to browser.<br />
Argument <code>log</code> has two fields: <code>input</code> - <code>res.log</code> input, <code>css</code> - style of input.<br/>
You may change this values for changing input value (e.g. using object field instead of whole log object) or changing item's style (e.g. mark different log levels with different colors) </td>
</tr>
<tr>
<td>sendCallback</td>
<td>function(req, res)</td>
<td>
<pre>
function(req, res) {
  res.log('beforeSend');
}
</pre>
</td>
</tr>
<tr>
<td colspan=3>Function that will be called right before calling <code>res.send</code>. Arguments are <code>req</code> and <code>res</code> objects</td>
</tr>
</table>

Next, you can use ```res.log(input)``` in your application and then logs will be sent to browser console with calling ```res.send``` or ```res.render```. Note that log will be sent to browser **ONLY** if content type is **html**. So don't worry about breaking your JSON or smth.

# Using with main log utility

All you need is your request-based log utility must have access to ```res.log```.
So you can specify ```res.log``` function as a one of destination functions (or streams) of main utility.

Example for [bunyan]:
```js
req.log = bunyan.createLogger({
    name: 'REQ',
    streams: [
        ...
        {
            level: 'debug',
            stream: {write: res.log},
            type: 'raw'
        }
        ...
    ]
});
...
app.get('/', function(req, res, next) {
    req.log.debug('This log will be sent in browser console!');
}
```

So all you need to do is send all your logs to ```res.log```.

If your main log utility is not much flexible, you can write custom fucntion that will send logs to each destination. Example:
```js
res.l = function() {
    this.log(arguments);
    req.anotherLogTool(arguments);
}
```

# Minimal example application
index.js:
```js
var express = require('express');
var app = express();

app.use(require('express-log2response')());
app.get('/', function(req, res, next){
    res.log('Requset path is ' + req.path);
    res.send('alloha');
});
app.listen(3001);
```

Run ```nodejs index.js``` and go to ```http://localhost:3001```
[bunyan]:https://github.com/trentm/node-bunyan

