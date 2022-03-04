git config --global user.name "Michelle Rogers"
git config --global user.email "michelleevarogers@gmail.com"
git config --global init.defaultBranch main

ssh-keygen -t ed25519 -C "michelleevarogers@gmail.com"
cat ~/.ssh/id_ed25519.pub

echo -e  "-> ssh-copy-id pi@10.10.10.3"