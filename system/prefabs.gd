extends Resource
class_name Prefabs

#gameplay
static var player = load("uid://el4p37wt8ws5")
static var enemy_base = load("uid://ffj6lvaha3uv")
static var enemy_charger = load("res://gameplay/enemies/enemy_charger.tscn")
static var enemy_spitter = load("res://gameplay/enemies/enemy_spitter.tscn")
static var enemy_armadillo = load("res://gameplay/enemies/enemy_armadillo.tscn")
static var enemy_projectile = load("res://gameplay/projectiles/enemy_projectile.tscn")
static var bit_pickup = load("res://gameplay/pickups/bit_pickup.tscn")
static var projectile_base = load("uid://do54f0pqxtq13")
static var weapon_base = load("res://gameplay/weapons/weapon_base.tscn")
static var grenade_ability = load("res://gameplay/abilities/grenade_ability.tscn")
static var grenade_projectile = load("res://gameplay/projectiles/grenade_projectile.tscn")
static var damage_number = load("res://gameplay/ui/damage_number.tscn")
static var upgrade_node = load("res://gameplay/upgrades/upgrade_node.tscn")

#vfx
static var hit_particles = load("res://gameplay/vfx/hit_particles.tscn")
static var grenade_explosion = load("res://gameplay/vfx/grenade_explosion.tscn")
static var death_debris = load("res://gameplay/vfx/death_debris.tscn")
static var spawn_effect = load("res://gameplay/vfx/spawn_effect.tscn")

#menus
static var menu_manager = load("uid://dqn0oxxoij7nf")
static var mainmenu_screen = load("uid://c3dru43fcfpyr")
static var upgrade_screen = load("res://menu_system/menus/upgrade_screen.tscn")
static var exit_confirm_screen = load("uid://bgruvykawye34")
static var pause_screen = load("uid://b8it2qmmqvtxa")
static var settings_screen = load("uid://07aw6acfhqq2")
static var title_screen = load("uid://6duclls5uod0")
