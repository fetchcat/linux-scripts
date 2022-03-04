#! /bin/bash

sh -c "$(curl -fsSL https://starship.rs/install.sh)"

echo -e '## Starship Prompt \n eval "$(starship init bash)"' >> ~/.bashrc