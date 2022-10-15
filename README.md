# Bitcoin Mining using Erlang
COP5615 - Distributed Operating Systems Principles Project 1

## Authors
* **Dishank Murari Poddar**
* **Dhananjaya Sathyanarayana Rao**

## Size of the work unit
In this project, we aim to simulate bitcoin mining by mining sha256 encoded strings in such a way that they satisfy a stipulated condition. A server node is set up to mine the coins and is also responisble for assigning work to worker nodes as and when they are available. A worker contacts a server and participates in mining with no set limitations on the number of coins that can be mined. Messages are passed between the server and worker processes to specify the input i.e the required number of leading 0s and ensure that the server is alive while the workers are mining coins. The resultant valid coins that the workers have mined are sent to the server and displayed by the server. The number of actors issued for both server and workers, are determined by using the number of Erlang schedulars available. We have measured the performance by running 2, 4 and 8 worker nodes with peak performance measured at an 8 worker node confugration. A configuration with a higher number of processes and nodes did not yield better results. We have set the server node to stop mining upon the completion of mining a hundred coins.(Hundred is chosen arbitrarily).

## Sample Output
A snippet of the sample output on the server node for an input of k=4, with a worker node initiated on a separate node.
```
dishankpoddar;YjJ4MjJ5NGFLNTBXeENUWWR5RkxNSUpPOTQ4MzdHN21BZVU2SHFDVy9zQT 
0000a035886ae4b74aed7ae58e14a653121764f72a71d3ae7fc98073877b0923


dishankpoddar;cEhEN080Z0hpZ20rT1pkNVpBZ2JUSEFiZWd5L0MyckZBbDVxWHBHTWgzOD 
000015ab907fbf567e6bb1d57373a3665207fd408b37dd7b33e747baeb47d782 from worker


dishankpoddar;ZHJ6K3FHeUdzYXhoUUNYdjB2RWtGWEt5OFhlbFdwZ3ZZbVJXczhaVVBUST 
0000ce2dc8b94a4957e079ec770716ac2f85c9729ddf5184aa63a0f27d4caa9c


dishankpoddar;ZGZQMGxhcnBGRXJ4a1R2NG96d2lGckppV1V0dkVzQVZ1UVllTVI4QkRNMD 
0000fcc008e14bab45d9f153e819607cfe4cf5978fd20d7c232bf33c4a469a7e from worker


dishankpoddar;VXZMN0R0bHZyZEFHQzlCVWNYdzRDc0RmV1FPZGZnYjlDSWtmVElTSUdpWT 
0000a7b83bf0cc1aec79f80c5badce102f0a8c394100ea73e86a434441cccb9c from worker
```

## Running Time
```
The work took 83447 cpu milliseconds and 41811 wall clock milliseconds - 2 worker processes
The work took 74404 cpu milliseconds and 22739 wall clock milliseconds - 4 worker processes
The work took 93543 cpu milliseconds and 18807 wall clock milliseconds - 8 worker processes
```
## Coin with the most zeroes - 7
dishankpoddar;STlFakV5Q0V0NzZyS1RHNUxvQXVBUFlVYXc4eWpGK3haT1BzMWVLakxVaz 000000066cd1356e0de87d66aa9dc7621a55423bab1637ae28705d597024876e

## Largest Number of working machines on which the code was run
The code was run simlutaneously on 8 machines.

## Getting Started

#### Erlang
Please use Erlang >= 20.0, available at <https://www.erlang.org/downloads>.

To install on a Mac, `brew install erlang`. (you may need to `brew update` first).

Alternatively, you can also follow [these instructions](http://elixir-lang.org/install.html).

## Running
Open a terminal at the file location where the .erl files are stored.

### Run the app on a server.
```
$ erl -name servername -setcookie cookiename.
```
The name can be set to name@server-ip.

Set the name in the .erl file to name@server-ip in the 'main_node' function.

After initiating the server erlang node,
```
c(btc).
btc:start_mining().

Enter number of leading 0s for a coin: k.
```
Here k is an input that represents the required number of leading 0s to be found in the hashed string.
### Run the app on a worker.
Ensure that the compiled code (.beam file) is stored in a location such that the worker can access the server.
```
$ erl -name workername -setcookie cookiename.
```
The name can be set to name@worker-ip.

After initiating the worker erlang node,
```
btc:join_as_worker().
```
Process ids for the worker node will have been returned indicating that the worker node has begun mining in correspondence with the server.

You may also start a worker node on the same device by opening a separate terminal and setting up the name and cookie.

## Built With

* [Erlang](https://www.erlang.org/) - Erlang is a programming language used to build massively scalable soft real-time systems with requirements on high availability.
* [Visual Studio Code](https://code.visualstudio.com/) - Source code editor.






