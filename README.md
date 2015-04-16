# BigMLKit

![alt tag](https://github.com/bigmlcom/BigMLKit/blob/master/BigMLKit.jpg)

BigMLKit brings the ease of “one-click-to-predict” to iOS and OS X developers by making it really easy to interact with BigML’s REST API though a higher-level view of a “task”.

A task is, in its most basic version, a sequence of steps that is carried out through BigML’s API. Each step has traditionally required a certain amount of work such as preparing the data, launching the remote operation, waiting for it to complete, collecting the right data to prepare the  next step and so on. BigMLKit takes care of all of this “glue  logics” for you in a streamlined manner, while also providing an abstracted way to interact with BigML and build complex tasks on top of our platform.

To get BigMLKit together will all of its dependencies, run:

    $ git clone --recurse-submodules https://github.com/bigmlcom/BigMLKit.git

In order to run BigMLKit unit tests, you need to provide your credentials in two separate files:

    BigMLKitTests/username.txt
    BigMLKitTests/apikey.txt

It is suggested that before or right after modifying those files, you run the following command:

    git update-index --assume-unchanged BigMLKitTests/apikey.txt BigMLKitTests/username.txt

to ensure that sensitive information is never pushed to a fork of yours.

# License

BigMLKit is open sourced under the
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
