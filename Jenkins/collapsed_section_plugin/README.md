# Collapsed section plugin
---


# In pipeline (groovy)

```
stage('Stage name'){
	println('BEGIN SECTION Stage name')
 	/* code block */
	println("End of Stage")
}
```
---

# In jenkins system settings

```
Section {2}

^(.*BEGIN SECTION)\s+(\w.+)$

(.*End of Stage)
```
---