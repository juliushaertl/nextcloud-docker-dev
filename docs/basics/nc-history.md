# Nextcloud server with history

The script `bootstrap.sh` will download a clone of the server code repository.
Depending on your use case, you might be interested in having the complete or a partial history of the Nextcloud server at your fingertips.

## TL;DR

If you want to have a quick and dirty solution to just bootstrap the dev environment, just use `./bootstrap.sh`.
If you want to intensively work on the server, use `./bootstrap.sh --full-clone`.
If you want to switch from time to time between server versions and save bandwidth/storage, use `./bootstrap.sh --clone-no-blobs`.

## Clone with depth one by default

If you do not provide any additional information to the bootstrap script, it will truncate the history of the server repository.
This truncation is done after exactly one commit.
That means the clone you will get will contain exactly this single commit.

!!! info
    This will create a clone with `--depth 1`.
    See the man page of git clone for more details on the implications.

As this is mainly the same data as the tarball, the download in this mode is the fastest of all options.

If you want to play around with the different server versions, you need to download these and unshallow the repository using `git fetch --unshallow`.
This will take quite some time and will download the complete server history.

## Clone with complete history

If you know that you will need the complete history of the server repository, you might want to avoid first creating a shallow copy and then unshallow it directly.
To cope with this, you can append `--full-clone` to the `./bootstrap.sh` command line:

```
./bootstrap.sh --full-clone
```

The benefit is that the complete repository is present and you can browse the history as you like.
The obvious drawback is that you have to download the complete history which might take a significant amount of time.

## Clone with the blobs filtered out

There is also one more option to the script, namely `--clone-no-blobs`.
This works only with a sufficiently recent version of git.
Instead of a shallow clone (where the history is truncated), a partial clone created by this parameter has the complete history attached.
In that sense, you can navigate the complete history as you like.
You would do the following to create such a partial clone:
```
./bootstrap.sh --clone-no-blobs
```

The main difference to a shallow clone is that the cloned repository will not download all files (git calls them _blobs_) stored in the past.
Instead, once you checkout a certain commit, git checks for all files if the corresponding file has been downloaded in the past.
If it was, it uses this copy.
If the file was not yet downloaded, a new connection to the upstream repository has to be made and the missing blobs are downloaded.
Just after the clone of such a partially cloned repo, git will download all blobs needed to view the (current) branch content.
This is very similar to the shallow clone where only the content of the last commit is downloaded.

As the complete history is generally known, you can use the normal git commands to handle such a repository.
You can just pull/fetch as you are used.
Switching a branch might download the required files on the fly.
Any later update (using `git fetch` or `git pull`) will respect the setting and also download no blobs directly.

!!! Info
    This will clone the repository with `--filter blob:none`.
    Again see the man page of `git clone` for more details.

The benefit of this approach is obviously that you can have a complete history that you can work with (as long as you do not need the file contents).
The initial clone takes a bit longer than the shallow one as additionally the history commits (without the contents) need to be transmitted.

The obvious drawback is that once you need to checkout a file that was never checked out in the clone, it has to be downloaded and a live internet connection is needed.
