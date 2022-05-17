# agda-net

Expose some of the functions from Haskell `network-simple` in Agda.

There are some caveats making this almost a toy. See the source code.

## example

Start a server in a terminal (caution: should start this server from an empty directory, and make sure to close it later)

```sh-session
$ python -m http.server 8081
Serving HTTP on 0.0.0.0 port 8081 (http://0.0.0.0:8081/) ...
```

Compile and run the compiled agda in a different terminal

```sh-session
$ agda --compile src/Test.agda
...

$ ./src/Test
Connecting to localhost:8081
Connected to server and making request
Serving on localhost:8080
```

Meanwhile, the python server will print out: (it is confused)

```text
127.0.0.1 - - [16/May/2022 17:10:02] code 400, message Bad request version ('data!')
127.0.0.1 - - [16/May/2022 17:10:02] "Please give me data!" 400 -
```

And now the agda demo is serving, so we can connect to it with `nc`:

```sh-session
$ nc localhost 8080
testing 1 2 3
Invalid request: Please say hello

$ nc localhost 8080
hello
Good day!

$
```

Meanwhile, the demo prints out:

```text
Got connection from: [::1]:56298
Waiting for client request
Got connection from: [::1]:56300
Waiting for client request
```

That's the end of the demo. Be sure to close both programs.
