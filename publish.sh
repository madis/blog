echo "Building"
jekyll build

echo "Deploying"
rsync --recursive --perms --compress --verbose _site/* mad.is:~/apps/blog/public

echo "Done"
