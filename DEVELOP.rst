===============
Developer Guide
===============


Preparing a release
===================

To create a new release, you must:

- Add a section for the new version in the ``CHANGES.txt`` file

- Update `message` in `docs/style.json` to the latest version

- Commit your changes with a message like "Prepare release X.Y.Z"

- Push to ``origin``

- Create a tag by running ``./devtools/create_tag.sh``
