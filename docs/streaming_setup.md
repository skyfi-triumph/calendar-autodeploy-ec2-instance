[Original guide](https://aws.amazon.com/blogs/gametech/enabling-quest-2-ar-vr-on-ec2-with-nice-dcv/). Ignore, we're doing things different. 

We'll use 3 remoting apps instead. Remote Desktop just for Windows maintenance stuff (eg, getting everything setup); Parsec for pancake gaming (traditional games); and Virtual Desktop for VR streaming. Note, we're not using NiceDCV (see bottom).

## Pancake Games

So instead, I recommend using Steam Remote Play. This sets Steam up on Windows as a server, then you can download the Steam Remote Play client to any of your devices (Mac, PC, web, mobile, etc). Then play from there.

## VR

The original tutorial used Oculus Link cable. You don't need it! Virtual Desktop allows wireless remote access. NiceDCV's whole USB filter string setup is such a pain in the ass, that this fact will reduce the tech requirements of that tutorial by half.

* Download / install [Oculus](https://www.oculus.com/setup/). Logging in through Facebook is really hard in this setup, Facebook detects malicious. It puts you through an account-verify infinite loop, and will lock you out if you try that loop too much. I recommend: in Chrome, do a reset-password on Facebook. Go through the password-completion steps *on Windows Server*, not localhost (though you may need to verify some stuff on localhost). 
* Steam. Install, then inside Steam install SteamVR. 
* [Virtual Desktop Streamer App](https://www.vrdesktop.net/). Not VD from Steam library, use this website.
  * On Quest, buy/install Virtual Desktop. It's like $10.
  * Run VD Streamer on Windows, connect to it from Quest.

### Virtual Desktop Tweaks

If you experience stutter, fiddle with Virtual Desktop streaming settings Quest-side. I disabled most options (ASW, Slicing, Video Buffer, etc) and things got substantially better. If anyone has more experience here, please drop recommendations.