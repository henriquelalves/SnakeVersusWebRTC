# SnakeVersusWebRTC
A simple Godot Peer-to-Peer browser game, made with WebRTC. I wrote an article on the project's multiplayer architecture [on my write.as blog](https://write.as/perons/creating-a-peer-to-peer-snake-game-with-godot-webrtc). You can play the project on it's [itch.io page](https://perons.itch.io/snake-versus).

[Imgur](https://i.imgur.com/N6kT1hS.png)

The two main folders are:

- godot-project: the Godot project folder in which both Client and Matchmaking Server are, built separately by a different export configuration.
- web: a web page boilerplate for the client.

The root of the project also has the gitlab-ci and the DockerClient/DockerServer files, used on GitLab to setup the CI so I could tag commits with "client-xx" or "server-yy", and have the project up and running on my server. You can use them as reference.
