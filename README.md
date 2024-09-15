# AudioManager
 A simple audio manager for Godot Engine

 ### Usage resume
1. Install the addon and enable it.
2. Inside the AudioManager tab, create and configure audio resources
3. Use the functions of the AudioManager to play the audio resources

### Install
- Add the addons/audio_manager folder to your addons folder
- Use the project settings to enable the plugin "AudioManager"

### Creating audio resources
Use the interface generated, accessible from the top tabs with name **AudioManager**

#### Audio resource settings
- **Name / tag**: it's used for the filename and to use the resource in the code. Has to be unique.
- **Volume**: audio volume to be used when playing the resource. Default to 1.
- **Pitch**: the pitch used as base for the resource. Default to 1.
- **Random pitch**: this value is used to give the resource a random pitch variation everytime is played. If pitch is set to 1, and the random pitch to 0.25, the audio will play in a random pitch between 0.75 and 1.25. Default to 0
- **Audio files**: the audio file to play when using this resource. If you assign more than one, a random file will be picked when playing the resource

### Using the audio resources
#### Main usage
```gdscript
# Play a sound without any world position
# play_sound(audio_name:String, delay:float = 0.0)
AudioManager.play("your_audio_resource_name")

# Play a sound with a 2D position
# play_sound2D(audio_name:String, world_pos: Vector2, delay:float = 0.0)
AudioManager.play2D("your_audio_resource_name", Vector2(10,5))

# Play a sound with a 3D position
# play_sound3D(audio_name:String, world_pos: Vector3, delay:float = 0.0)
AudioManager.play3D("your_audio_resource_name", Vector3(10,5,80))
```

#### Play delayed
All functions has the last parameter set to delay, to play the sound after X seconds
```gdscript
AudioManager.play("your_audio_resource_name", 1.5)
AudioManager.play2D("your_audio_resource_name", Vector2(10,5), 1.5)
AudioManager.play3D("your_audio_resource_name", Vector3(10,5,80), 1.5)
```
