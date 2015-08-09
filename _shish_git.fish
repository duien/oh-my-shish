function _shish_git -a info

  switch $info
    case root
      echo (command git rev-parse --show-toplevel ^/dev/null)
    case dirty
      echo (command git diff --no-ext-diff --quiet --exit-code; or echo -n '*')
    case staged
      echo (command git diff --cached --no-ext-diff --quiet --exit-code; or echo -n '~')
    case stashed
      echo (command git rev-parse --verify --quiet refs/stash >/dev/null; and echo -n '$')
    case untracked
      set -l new (command git ls-files --other --exclude-standard);
      [ "$new" ]; and echo '…'
    case ahead
      echo (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null | awk '/>/ {a += 1} /</ {b += 1} {if (a > 0) nextfile} END {if (a > 0 && b > 0) print "±"; else if (a > 0) print "+"; else if (b > 0) print "-"}')
   end
end
