# Requires PowerShell 5+

# --- Configuration (edit as needed) ---
$RepoUrl      = 'https://github.com/kolelan/create_structure.git'
$RawScriptUrl = 'https://raw.githubusercontent.com/kolelan/create_structure/refs/heads/main/create_structure.py'
$ScriptPath   = Join-Path -Path (Get-Location) -ChildPath 'create_structure.py'
$StructureTxt = Join-Path -Path (Get-Location) -ChildPath 'structure.txt'
$MinPyMajor   = 3
$MinPyMinor   = 8
# --------------------------------------

$ErrorActionPreference = 'Stop'

function Get-Python {
	$pythonCandidates = @('python', 'py -3', 'py')
	foreach ($cmd in $pythonCandidates) {
		try {
			$versionOutput = & $cmd --version 2>&1
			if ($LASTEXITCODE -eq 0 -or $versionOutput) {
				return $cmd
			}
		} catch {}
	}
	throw 'Python not found. Please install Python 3.8+ and ensure it is on PATH.'
}

function Test-PythonVersion {
	param(
		[string] $PythonCmd
	)
	$versionOutput = (& $PythonCmd --version 2>&1).Trim()
	if (-not $versionOutput) { throw 'Unable to determine Python version.' }
	# Expect: Python X.Y.Z
	$parts = $versionOutput -replace '^Python\s+', '' -split '\.'
	if ($parts.Count -lt 2) { throw "Unexpected Python version string: $versionOutput" }
	$maj = [int]$parts[0]
	$min = [int]$parts[1]
	if ($maj -lt $MinPyMajor -or ($maj -eq $MinPyMajor -and $min -lt $MinPyMinor)) {
		throw "Python $MinPyMajor.$MinPyMinor+ required. Detected: $versionOutput"
	}
	Write-Host "Using $versionOutput"
}

function Ensure-CreateStructureScript {
	if (Test-Path -Path $ScriptPath) { return }
	Write-Host "create_structure.py not found. Downloading from repository..."
	try {
		Invoke-WebRequest -Uri $RawScriptUrl -OutFile $ScriptPath -UseBasicParsing
		Write-Host 'Downloaded create_structure.py from raw URL.'
	} catch {
		Write-Warning "Direct download failed: $($_.Exception.Message)"
		# Fallback: try git clone if available
		try {
			$gitVersion = (& git --version 2>$null)
			if (-not $gitVersion) { throw 'git not available' }
			$tempDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("create_structure_" + [System.Guid]::NewGuid().ToString()))
			& git clone --depth 1 $RepoUrl $tempDir.FullName | Out-Null
			$src = Join-Path $tempDir.FullName 'create_structure.py'
			if (-not (Test-Path $src)) { throw 'create_structure.py not found in cloned repo' }
			Copy-Item $src -Destination $ScriptPath -Force
			Write-Host 'Copied create_structure.py from cloned repository.'
		} catch {
			throw "Failed to retrieve create_structure.py from repo: $($_.Exception.Message)"
		}
	}
}

function Test-StructureTxtHasContent {
	if (-not (Test-Path -Path $StructureTxt)) {
		throw "Required file not found: $StructureTxt"
	}
	$lines = Get-Content -Path $StructureTxt -ErrorAction Stop | Where-Object { $_.Trim().Length -gt 0 }
	if (-not $lines -or $lines.Count -eq 0) {
		throw "No entries found in $StructureTxt. Add at least one non-empty line."
	}
	Write-Host "Found $($lines.Count) entries in structure.txt"
}

try {
	$py = Get-Python
	Test-PythonVersion -PythonCmd $py
	Test-StructureTxtHasContent
	Ensure-CreateStructureScript
	Write-Host 'Running create_structure.py...'
	& $py $ScriptPath
	if ($LASTEXITCODE -ne 0) { throw "create_structure.py exited with code $LASTEXITCODE" }
} catch {
	Write-Error $_.Exception.Message
	exit 1
}
