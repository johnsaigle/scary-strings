# Directories containing wordlists.
# Each may have subcategory files and an auto-generated 'all' file.
WORDLIST_ROOT := wordlists

.PHONY: all sort clean-all check

# Default: sort subcategory files in-place, then (re)generate every 'all'.
all: sort generate

# Sort each subcategory file in-place (skip 'all' files, dotfiles, and docs).
sort:
	@find $(WORDLIST_ROOT) -type f ! -name 'all' ! -name '.*' ! -name '*.md' \
		-exec sort -o {} {} \;
	@echo "Sorted all subcategory files."

# Build / update every 'all' file.
#
# For each directory that has at least one non-'all' file, merge all
# subcategory files together with the existing 'all' (to preserve any
# standalone entries), then sort -u the result.
generate:
	@find $(WORDLIST_ROOT) -type f ! -name 'all' ! -name '.*' ! -name '*.md' -printf '%h\n' \
	| sort -u \
	| while read -r dir; do \
		files=$$(find "$$dir" -maxdepth 1 -type f ! -name 'all' ! -name '.*' ! -name '*.md' | sort); \
		if [ -n "$$files" ]; then \
			cat $$files "$$dir/all" 2>/dev/null | sort -u > "$$dir/all.tmp" && \
			mv "$$dir/all.tmp" "$$dir/all" && \
			echo "Updated $$dir/all"; \
		fi; \
	done

# Remove generated 'all' files (only in directories that have subcategory
# files — directories where 'all' is the only file are left untouched).
clean-all:
	@find $(WORDLIST_ROOT) -type f ! -name 'all' ! -name '.*' ! -name '*.md' -printf '%h\n' \
	| sort -u \
	| while read -r dir; do \
		[ -f "$$dir/all" ] && rm "$$dir/all" && echo "Removed $$dir/all"; \
	done; true

# Verify that every subcategory entry appears in its directory's 'all' file.
# Exits non-zero if any entries are missing (useful in CI).
check: sort
	@rc=0; \
	for dir in $$(find $(WORDLIST_ROOT) -type f ! -name 'all' ! -name '.*' ! -name '*.md' -printf '%h\n' | sort -u); do \
		files=$$(find "$$dir" -maxdepth 1 -type f ! -name 'all' ! -name '.*' ! -name '*.md' | sort); \
		if [ -n "$$files" ]; then \
			missing=$$(comm -23 <(cat $$files | sort -u) <(sort -u "$$dir/all" 2>/dev/null)); \
			if [ -n "$$missing" ]; then \
				echo "STALE: $$dir/all  (missing: $$(echo $$missing | tr '\n' ' '))"; \
				rc=1; \
			fi; \
		fi; \
	done; \
	if [ $$rc -eq 0 ]; then echo "All 'all' files are up to date."; fi; \
	exit $$rc
