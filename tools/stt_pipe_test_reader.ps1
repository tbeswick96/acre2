# Throwaway STT stand-in: serve \\.\pipe\uksf_stt, parse START/DATA/END frames,
# write each utterance's PCM to a 48kHz mono 16-bit WAV, log boundaries.
# Run BEFORE toggling the in-game debug gate. Ctrl+C to stop.
param([string]$OutDir = "$PSScriptRoot\stt_out")

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Add-Type -AssemblyName System.Core

function Read-Exact($stream, [int]$count) {
    $buf = New-Object byte[] $count
    $off = 0
    while ($off -lt $count) {
        $n = $stream.Read($buf, $off, $count - $off)
        if ($n -le 0) { return $null }
        $off += $n
    }
    return $buf
}

function Write-Wav([string]$path, [byte[]]$pcm, [int]$rate, [int]$channels) {
    $byteRate = $rate * $channels * 2
    $fs = [System.IO.File]::Create($path)
    $bw = New-Object System.IO.BinaryWriter($fs)
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes("RIFF"))
    $bw.Write([int](36 + $pcm.Length))
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes("WAVE"))
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes("fmt "))
    $bw.Write([int]16); $bw.Write([int16]1); $bw.Write([int16]$channels)
    $bw.Write([int]$rate); $bw.Write([int]$byteRate)
    $bw.Write([int16]($channels * 2)); $bw.Write([int16]16)
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes("data"))
    $bw.Write([int]$pcm.Length); $bw.Write($pcm)
    $bw.Close(); $fs.Close()
}

while ($true) {
    Write-Host "Waiting for ACRE on \\.\pipe\uksf_stt ..."
    $server = New-Object System.IO.Pipes.NamedPipeServerStream("uksf_stt",
        [System.IO.Pipes.PipeDirection]::In, 1,
        [System.IO.Pipes.PipeTransmissionMode]::Byte)
    $server.WaitForConnection()
    Write-Host "Connected."
    $rate = 48000; $channels = 1; $uttId = 0
    $pcm = New-Object System.Collections.Generic.List[byte]
    try {
        while ($true) {
            $hdr = Read-Exact $server 8
            if ($null -eq $hdr) { break }
            $type = [BitConverter]::ToUInt32($hdr, 0)
            $len  = [BitConverter]::ToUInt32($hdr, 4)
            $payload = if ($len -gt 0) { Read-Exact $server $len } else { @() }
            if ($null -eq $payload) { break }
            switch ($type) {
                1 { $rate = [BitConverter]::ToUInt32($payload,0)
                    $channels = [BitConverter]::ToUInt32($payload,4)
                    $uttId = [BitConverter]::ToUInt32($payload,8)
                    $pcm.Clear()
                    Write-Host "START utt=$uttId rate=$rate ch=$channels" }
                2 { $pcm.AddRange($payload) }
                3 { $endId = [BitConverter]::ToUInt32($payload,0)
                    $out = Join-Path $OutDir "utt_$endId.wav"
                    Write-Wav $out $pcm.ToArray() $rate $channels
                    Write-Host "END utt=$endId -> $out ($($pcm.Count) bytes)" }
                default { Write-Host "Unknown frame type $type len $len" }
            }
        }
    } finally { $server.Dispose() }
    Write-Host "Disconnected; waiting again."
}
