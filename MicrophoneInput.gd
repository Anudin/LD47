extends Node


signal loudness_available


var mic: AudioEffectRecord
const MIN_RECORD_LENGTH = 0.25
var time_passed = 0


func _ready():
	mic = AudioServer.get_bus_effect(AudioServer.get_bus_index("Record"), 0)
	mic.set_recording_active(true)


func _process(delta):
	if mic.is_recording_active() and time_passed >= MIN_RECORD_LENGTH:
		time_passed = 0
		var recording = read_16bit_samples(mic.get_recording())
		emit_signal("loudness_available", recording.max())
		mic.set_recording_active(true)	
	time_passed += delta


# https://godotengine.org/qa/67091/how-to-read-audio-samples-as-1-1-floats
static func read_16bit_samples(stream: AudioStreamSample) -> Array:
    assert(stream.format == AudioStreamSample.FORMAT_16_BITS)
    var bytes = stream.data
    var samples = []
    var i = 0
    # Read by packs of 2 bytes
    while i < len(bytes):
        var b0 = bytes[i]
        var b1 = bytes[i + 1]
        # Combine low bits and high bits to obtain 16-bit value
        var u = b0 | (b1 << 8)
        # Emulate signed to unsigned 16-bit conversion
        u = (u + 32768) & 0xffff
        # Convert to -1..1 range
        var s = float(u - 32768) / 32768.0
        samples.append(s)
        i += 2
    return samples
