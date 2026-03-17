⚙️ What Defines “Core System State”
A system is fully defined (at package level) by:

1. Installed packages → dpkg
2. Installation intent → apt-mark
3. Repositories → /etc/apt/sources.list*
4. Configurations → /etc/


For accurate system reconstruction and diffing, the correct model is:
DPKG = state
APT-MARK = intent
APT = mechanism


 # Ground truth (everything installed)
 dpkg --get-selections
 
 # User intent (what you chose to install)
 apt-mark showmanual
 
 # Optional: full package list with versions
 apt list --installed


alias apps-all='dpkg --get-selections'
alias apps-manual='apt-mark showmanual'
alias apps-installed=' apt list --installed'
