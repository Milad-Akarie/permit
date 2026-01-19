# Permit CLI — Examples

This file shows a few practical examples for using the `permit` command-line tool from this repository.

## Common command examples

- List permissions (show Android only):

```bash
permit list -a
```

- List only permissions that generate code:

```bash
permit list -c
```

- Add an Android-only permission and generate plugin code:

```bash
permit add android.permission.RECORD_AUDIO -c
```

- Add an iOS usage description (non-interactive with -d):

```bash
permit add NSCameraUsageDescription  -d "Required to take photos"
```

- Prompt to select permissions resulting from a search key and add them:
```bash
permit add camera 
```

- Remove a permission from Android only:

```bash
permit remove camera -a
```

- Manually trigger code generation after editing files:

```bash
permit build
```
