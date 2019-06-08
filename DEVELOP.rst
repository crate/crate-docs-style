===============
Developer Guide
===============


Preparing a release
===================

To create a new release, you must:

- Add a section for the new version in the ``CHANGES.txt`` file

- Commit your changes with a message like "prepare release x.y.z"

- Push to ``origin``

- Create a tag by running ``./devtools/create_tag.sh``
