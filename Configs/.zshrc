# Add user configurations here
# For HyDE to not touch your beloved configurations,
# we added 2 files to the project structure:
# 1. ~/.hyde.zshrc - for customizing the shell related hyde configurations
# 2. ~/.zshenv - for updating the zsh environment variables handled by HyDE // this will be modified across updates

#  Plugins 
# oh-my-zsh plugins are loaded  in ~/.hyde.zshrc file, see the file for more information
plugins=(archlinux alias-finder autojump colored-man-pages command-not-found dirhistory)

#  Aliases 
# Add aliases here

#  This is your file 
# Add your configurations here
export EDITOR=vim
# export EDITOR='vscodium --ozone-platform=wayland --enable-unsafe-webgpu --enable-features=Vulkan' 
zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default
