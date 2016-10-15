---
layout: post
title: Blocking outgoing traffic to ports
---

Controlling network traffic by using firewalls can have different benefits. There are also scenarios where restrictive rules just impede the users without giving any security benefits. This article describes in layman's terms using visual examples, the workings and results of blocking outoing traffic to specific ports.

Recently I was in an interesting situation when I had to use network that had blocked outgoing traffic to all ports besides *80* and *443*. I have worked with clients that have similar, very strict firewall rules. There can be different reasons for these: lack of knowledge on computer networks, paranoid about security or something else. I will explain here in simple terms what blocking outgoing traffic to ports means and what it can achieve. Hopefully it will be educational and help to create more useful and still secure firewall configurations.

> Disclaimer: this is simplified view of the underlying technology. For brevity, the analogies leave out many technical details.

## TL;DR version

Blocking outgoing ports (only allowing standard web ports *80* and *443*) will cause only cause inconvenience and does not provide additional security. Reason being - it is OUTGOING connection port. The connection has to be initiated from within the network.

## Visual analogue

Lets say your wifi network (WLAN) is a house. It has many doors, each of them has a number, starting from *1*. Something else that is interesting about the doors is that you can only open them one way: that is from inside out. Most often you use doors *80* and *443*. You use these two to go to bank, read news and get DVD-s. You could use any other door for these activities but it is agreed between everybody that these two doors give access to these activities.

Now your friend comes by. He needs to get some books from library and send in his crossword puzzle solutions. Usually library is behind door *22* and crossword puzzle answers can be sent through door *1194*.

Now if you tell your friend: "I know I have many doors but you must use either *80* or *443*", will probably be confused. He will try to convince you to to let him use the other doors because they are already there and there is no risk involved because the doors only open from inside. If you say no, all your friend has to do is to call the library and tell: "I can't access you through door *22*, could you please come to door *80*".

As long as there is at least 1 door, everything can be done. Denying the standard way of doing things and forcing to use more inconvenient ways for no additional benefit seems like a weird thing to do for a friend.

![Door confusion](/assets/blocking-outgoing-traffic/confused_at_door.jpg)

## Computer terms

To exchange information between computers, there needs to be a connection between them. To make this connection 2 parts of information is needed: *address* and *port*. Address is like a house. Port is like a door.

When you open web page for 'https://google.com/', your browser will find out address (IP address) for the name *google.com* and then create connection to door(TCP port) *443*.

There is much more to the internet than just web pages (the stuff behind doors *80* and *443*). Other services / protocols  like databases, SSH servers, VPN services, games, email servers and many more use different ports.

Blocking outgoing traffic to ports will not make any services unaccessible but will just add couple steps to access them. It does not provide any security benefits. It is just inconvenient and when done for no good reason, can appear unkind or hostile.

In technical terms, all the user has to do is to set his service to listen on one of the allowed ports (*80*, *443*). Easiest way is to just configure a VPN server to be listen on *443* port and do everything else from there.

Blocking outgoing traffic could help if the intruder is already in the system. But this would require a lot of attention to do correctly so that existing services continue to work. Recent malware is already communicating over HTTP/HTTPS ports because it assumes the other ports could be blocked already.

## Conclusion

Restricting outgoing traffic to very few ports can seem like a simple solution at first. Often the policy of "Lock everything, so nothing bad can happen" makes the network just harder to use without protecting against intrusions.

## References

1. [Transmission Control Protocol, Wikipedia](https://en.wikipedia.org/wiki/Transmission_Control_Protocol)
2. [Internet Protocol, Wikipedia](https://en.wikipedia.org/wiki/Internet_Protocol)
3. [Block outgoing access to selected or specific IP address/port](http://www.cyberciti.biz/tips/linux-iptables-6-how-to-block-outgoing-access-to-selectedspecific-ip-address.html)
4. [Why block outgoing network traffic with a firewall](http://security.stackexchange.com/questions/24310/why-block-outgoing-network-traffic-with-a-firewall)
