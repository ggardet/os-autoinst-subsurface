This is the openqa/os-autoinst test repo for Subsurface

# Installation guide

- Install os-autoinst from the repo of your Linux distribution
- Then, you may need to apply a patch to be able to run Fedora tests without problem
[https://github.com/os-autoinst/os-autoinst/commit/1233c044096be3968fe5adf4a00bb0a12bb1f03f.patch](https://github.com/os-autoinst/os-autoinst/commit/1233c044096be3968fe5adf4a00bb0a12bb1f03f.patch)

- Get openSUSE infos for os-autoinst soft

  ```
  git clone https://github.com/os-autoinst/os-autoinst-distri-opensuse.git
  ```

- And/or get Fedora infos for os-autoinst soft

  ```
  git clone https://pagure.io/fedora-qa/os-autoinst-distri-fedora.git
  ```

- Get needles and tests:

  ```
  git clone https://github.com/ggardet/os-autoinst-subsurface
  ```

- Create symlink from os-autoinst-distri-{opensuse, fedora}/tests/subsurface to point to os-autoinst-subsurface/tests/subsurface/ 

  ```
  ln -s ../../os-autoinst-subsurface/tests/subsurface/ os-autoinst-distri-opensuse/tests/subsurface 
  ln -s ../../os-autoinst-subsurface/tests/subsurface/ os-autoinst-distri-fedora/tests/subsurface
  ```


- ISO:
  - Get latest openSUSE Tumbleweed Live KDE:
  ```
  wget http://download.opensuse.org/tumbleweed/iso/openSUSE-Tumbleweed-KDE-Live-x86_64-Snapshot20171010-Media.iso
  ```
  - And/or Fedora 26 Live KDE :
  ```
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/26/Spins/x86_64/iso/Fedora-KDE-Live-x86_64-26-1.5.iso
  ```
  - And create symlinks in `isos/` folder (we do not want to strore big ISO files in this repo)



# Running tests

- To start a test for openSUSE (or anyother supported distribution), please go to the right sub-folder (`opensuse/` or `fedora/`) and start the test with:
  ```
  isotovideo
  ```

- You can follow what is going on with a VNC client:
  ```
  vncviewer localhost:90 -ViewOnly -Shared
  ```

# Checking tests

Once the tests are done, you can easily check the results with:

  ```
  perl check_results.pl <path_to_test_results>
  ```

So, for openSUSE, it will be:

  ```
  perl check_results.pl ../opensuse/testresults/
  ```

It will show information in the console, and also generate HTML reports.


# Information on files from this repo

- **main.pm** : is the *main* file which configure the test framework and launch the tests
- **needles/*.{png,json}**: those are the images (previous screenshots) to compare to, limited to the area defined in the JSON file.
- **{fedora, opensuse}/vars.json**: informations for os-autoinst app ('isotovideo')
- **tests/subsurface/*.pm**: the tests launched from main.pm file


# Create / update needles (tests) 

- Please have a look at: 
 - existing needles
 - openqa test api page : [http://open.qa/api/testapi/](http://open.qa/api/testapi/)
