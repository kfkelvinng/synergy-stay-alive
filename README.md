Synergy has been unstable on my Ubuntu 14 for a while. I keep my ThinkPad E531 laptop attached to my kelvin-pc while I am at home.
Placing this script in crontab would restart synergc for me every so often while the hash of the apr output match the one at home.



```
crontab -e
```



```
* * * * * /path/to/the/synergy_stay_alive.sh
```

