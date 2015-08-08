set powerline_right \uE0B0
set powerline_right_soft \uE0B1
set powerline_left \uE0B2
set powerline_left_soft \uE0B3
set powerline_branch \uE0A0

#         red    green  yellow blue   purple cyan   orange
# bright  f73028 b8bb26 fabd2f 83a598 d3869b 7db669 fe8019
# neutral cc241d 98971a d79921 458588 b16286 578e57 d65d0e
# faded   890009 66620d a56311 0e5365 7b2b5e 356a46 9d2807
#
# grayscale 1d2021 282828 32302f 3c3836 504945 665c54 7c6f64 928374 a89984 bdae93 d5c4a1 ebdbb2 f2e5bc fbf1c7 f9f5d7

# Use $COLUMNS to determine window width

set red    f73028 cc241d 890009
set orange fe8019 d65d0e 9d2807
set yellow fabd2f d79921 a56311
set green  b8bb26 98971a 66620d
set cyan   7db669 54a367 00875f
# set blue   83a598 458588 0e5365
set blue   87afaf 458588 005f87 # trying term color codes instead
set purple d3869b b16286 7b2b5e
set grayscale 1d2021 282828 32302f 3c3836 504945 665c54 7c6f64 928374 a89984 bdae93 d5c4a1 ebdbb2 f2e5bc fbf1c7 f9f5d7

set bg_normal $grayscale[2]

# TODO Return status of last command
function fish_prompt
  set -l segments (math $COLUMNS/25)

  set -l git_root (command git rev-parse --show-toplevel ^/dev/null)
  if [ "$git_root" ]
    set -l path_bits (_shish_segments $git_root)
    set -l dir_inside_git (echo "$PWD" | sed -e "s#$git_root##g" -e 's#^/##')
    set -l path_bits_inside (_shish_segments $dir_inside_git)
    set -l inside_length
    if [ $dir_inside_git ]
      set inside_length (count $path_bits_inside)
      if [ $inside_length -gt (math $segments-1) ]
        set inside_length (math $segments-1)
      end
    else
      set inside_length 0
    end
    set -l outside_length (math $segments-1-$inside_length)

    set -l dirty (_shish_git dirty)
    set -l staged (_shish_git staged)

    set -l status_colors
    if [ $dirty ] ; set status_colors $orange
    else if [ $staged ] ; set status_colors $yellow
    # else if [ $stashed ] ; set status_colors $yellow
    # else if [ $ahead ] ; set status_colors $green
    else ; set status_colors $cyan
    end

    set -l ref (command git symbolic-ref HEAD ^/dev/null)
    set -l fg_branch $purple[1]
    set -l bg_branch $grayscale[1]
    if [ $status -gt 0 ]
      set -l branch (command git show-ref --head -s --abbrev | head -n1 ^/dev/null)
      set ref $branch
      set bg_branch $grayscale[-1]
      set fg_branch $purple[3]
    end
    set ref (echo $ref | sed  "s#refs/heads/##")
    if [ "master" = $ref ]
      set fg_branch $purple[3]
    end

    # everything leading up to git root
    if test $outside_length -gt 0
      _shish_cprintf $grayscale[4] $grayscale[6] ' '
      _shish_list $outside_length " $powerline_right_soft " $grayscale[4] $grayscale[7] $grayscale[5] $path_bits[1..-2]
      _shish_transition $grayscale[4] $bg_branch $powerline_left
    else
      _shish_cprintf $bg_branch $status_colors[1] ' '
    end

    # git branch / status
    set -l branch_segments (_shish_segments $ref)
    if [ (count $branch_segments) -gt 1 ]
      _shish_list (count $branch_segments) '/' $bg_branch $purple[3] $purple[3] $branch_segments[1..-2]
      _shish_cprintf $bg_branch $purple[3] '/'
    end
    _shish_cprintf $bg_branch $fg_branch $branch_segments[-1]
    _shish_transition $bg_branch $status_colors[3] $powerline_right true

    # the git root
    _shish_cbprintf $status_colors[3] $grayscale[-1] $path_bits[-1]

    # and the dir inside git
    if test $inside_length -gt 0
      _shish_cprintf $status_colors[3] $status_colors[2] " $powerline_right_soft "
      _shish_list $inside_length " $powerline_right_soft " $status_colors[3] $status_colors[1] $status_colors[2] $path_bits_inside
    end
    _shish_transition $status_colors[3] $bg_normal $powerline_right true
  else
    # not inside of git

    _shish_cprintf $grayscale[4] $grayscale[7] ' '
    _shish_pwd $segments " $powerline_right_soft " $grayscale[4] $grayscale[7] $grayscale[5] $grayscale[-1] (_shish_segments $PWD)
    _shish_transition $grayscale[4] $bg_normal $powerline_right true
  end
end
