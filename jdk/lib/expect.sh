spawn ssh localhost
expect {
 "*yes/no" { send "yes\r"; exp_continue}
 "*#" {set timeout 2; send "exit\r";}
}
spawn ssh 127.0.0.1
expect {
 "*yes/no" { send "yes\r"; exp_continue}
 "*#" {set timeout 2; send "exit\r";}
}
spawn ssh 0.0.0.0
expect {
 "*yes/no" { send "yes\r"; exp_continue}
 "*#" {set timeout 2; send "exit\r";}
} 
interact 
