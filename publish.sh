echo "Making all assets readable"
find assets -type f -exec chmod 644 {} \;

echo "Building"
jekyll build

echo "Deploying"
rsync --recursive --perms --compress --verbose _site/* deployer@mad.is:~/apps/blog/public

echo "Done"
