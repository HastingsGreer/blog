# Jupiter Interferometric Observatory

**Author:** hastings.greer

**Date:** January 2026

## Introduction

Jupiter's second Lagrange point is absurdly cold, quiet and gravitationally flat. It sits entirely in Jupiter's umbra, which in this vicinity is a 12 kelvin cylinder >50,000 km across. As a result, our proposed 150 kg spacecraft with 100 watts of power from an RTG can station keep and maneuver in formation using just radiation pressure from LEDs. This form of maneuvering makes picometer adjustments easy with no moving parts. The constraint on precision positioning is purely measurment, actuation is as easy as PWM.

The proposed telescope parameters: 30 primary mirrors, each on its own bus, flying in formation along a 160 km paraboloid. One collection scope on a bus at the focus 300 km away. Collection scope images the aperture, and this is masked to only allow light from the primary mirrors, then an image is formed with XXx magnification onto a 45 x 45 array of frequency sensitive single photon counters.

## Illumination environment

umbra math

illumination from jupiter

illumination from cmb

## radiation

details from new horizons and ulysses, punchline is that we are way outside the worst of jupiters radiation belts (~half an AU from jupiter) but will get hit by occasional plasma blobs as we are in the magnetotail. Don't have to worry about solar wind.

## point spread function

mirror smoothness- assume throughout that jwst mirror segments are used, scaled down to 1 m diameter

image of earth from alpha centauri- resolved to continent scale

## manuvering

```python
sun_mass = 1.989e30
jupiter_mass = 1.898e27
G = 6.6743e-11
jupiter_perihelion = 740000000000

jupiter_velocity = 13726

jupiter_orbit_time = 374100000

c = 3e8

bus_mass = 150 # 50 kg rtg (curiousity reference), 20 kg mirror (JWST reference), 20 kg metrology (grace reference) 60 kg structure, strut between active section and mirror, baffles along structure, leds, etc

import numpy as np
def ddt (t, state):
    sun_v = state[:2]
    sun_r = state[2:4]
    jupiter_v = state[4:6]
    jupiter_r = state[6:]

    r = sun_r - jupiter_r
    ur = r / np.linalg.norm(r)

    d = np.linalg.norm(r)

    F = G * sun_mass * jupiter_mass / d **2

    jupiter_a = F / jupiter_mass * ur
    sun_a = -F / sun_mass * ur

    #print(sun_a, sun_v, jupiter_a, jupiter_v)

    return np.concatenate([sun_a, sun_v, jupiter_a, jupiter_v])

import scipy
orbits = 1
t = np.linspace(0, orbits * jupiter_orbit_time, 1000)
solution = scipy.integrate.solve_ivp(
    ddt, 
    (0, orbits * jupiter_orbit_time), 
    [0, 0, 0, 0, 0, jupiter_velocity, jupiter_perihelion, 0], 
    t_eval=t,
    rtol=1e-10, 
    atol=1e-13,
)
y = solution.y
np.min(y[6])

sun_v = y[:2]
sun_r = y[2:4]
jupiter_v = y[4:6]
jupiter_r = y[6:]

dy = np.array([ddt(0, y[:, i]) for i in range(len(y[0]))]).transpose()

import matplotlib.pyplot as plt

dy[:, 100]

lagrange_factor = 1.0697710199
scope_position = lagrange_factor * jupiter_r + (1 - lagrange_factor) *  sun_r + np.array([[300000], [0]])
scope_acceleration = lagrange_factor * dy[4:6] + (1 - lagrange_factor) *  dy[0:2] 

d_sun = scope_position - sun_r
dist_sun = np.sqrt(d_sun[0]**2 + d_sun[1]**2)
du_sun = d_sun / dist_sun
acc_sun = -G * sun_mass * du_sun / dist_sun**2
d_jupiter = scope_position - jupiter_r
dist_jupiter = np.sqrt(d_jupiter[0]**2 + d_jupiter[1]**2)
du_jupiter = d_jupiter / dist_jupiter
acc_jupiter = -G * jupiter_mass * du_jupiter / dist_jupiter**2

control_authority = acc_sun + acc_jupiter - scope_acceleration
control_power = c * bus_mass * np.max(np.abs(control_authority))
print(control_power) # 30 watts
```

Sanity check: control authority needed is 7.127966317774063e-10 m/s^2, pioneer anomaly is (8.74±1.33)×10−10 m/s2 so making a spaceship that manuevers with this level of acceleration via RTG emmission is doable by construction. Seebeck + LED is just a chosen way to modulate this effect without vibration.

## RTG constraints

focal length defines needed thrust to weight ratio.

americium? 

balanced emission of waste heat

led efficiency, seebeck efficiency

configuration 

mirror + piston retroreflector - |cryobaffles|-led-cluster - - - >[rtg]< - - - led-cluster&cpu&lateral metrology equipment & star trackers - | baffle

matched baffles on either side of rtg along boom endure symmetric infrared radiation, such that assymetries can be corrected by led thrusters. 

## metrology

Piston: just copy paste grace-fo. 200 Picometer sqrt hz measurement.

lateral: ah. This is actually important, will require laser paths between primary mirror busses. again, Off the shelf tech, copy paste grace-fo

steering: hubble level pointing stability is all that is needed, but this is not actually trivial- hubble could hold a beam with the required steadiness, but couldn't necessarily point accurately enough without feedback to land the beam on the secondary mirror.

Feedback solution: array of small cameras on the hub forms a light field camera. From each camera, each of the 30 primary mirrors looks like a dim star because it is reflecting the host star of the target exoplanet. Light field camera is several meters across, brightness of the primary mirrors varies for each of the element cameras- this can be fit to an aerie pattern to work out exactly how each of the primary mirrors is tilted (real image of the host star is formed at the plane by each primary mirror, lightfield camera elements prevent interference between primary mirrors, this is a little complex actually)

This allows steering all the light from the exoplanet into the hub secondary mirror (actually involves putting the center of the measured aerie disk ~1-2 meters away from the secondary mirror, because this is the distance between the image of the host star and the image of the exoplanet- focal length here is absurdly long for this to be true)

## Star nulling

When imaging an exoplanet, move the mirrors into _pairs_ separated by ~100m so that each primary pair sends a deep null to the exoplanet imaging array

Distributed lightfield camera directly images the resulting fringes, allows closed loop control per pair

pairs actually stay on the paraboloid. Piston error achievable by this fringe tracking is much tighter than total error (which can be up to 20 nanometers without much damage, see appendix b)

Note: paraboloid is apparently meaningfully the wrong shape- need an ellipsoid to get the path lengths right (!) for nearby stars

## total mass budget and delivery to l2

150 * 30 + ~2000 for the hub scope. No problem for falcon heavy.

hi musk

## the tides of saturn

## Appendix b

```python
from mpmath import mp, mpf, mpc, sqrt, exp, pi, cos, sin, fabs
import numpy as np
import matplotlib.pyplot as plt

plt.savefig = lambda *y, **x: plt.show()
mp.dps = 100

wavelength = mpf('500e-9')
baseline = mpf('160000')
focal_length = mpf('300000')
n_primaries = 30

theta_res = wavelength / baseline
res_element_detector = focal_length * theta_res

print("=" * 70)
print("SPARSE APERTURE PSF ANALYSIS")
print("=" * 70)
print(f"Baseline: {float(baseline)/1000} km")
print(f"Number of mirrors: {n_primaries}")
print(f"Resolution: {float(theta_res):.3e} rad")
print(f"Detector res element: {float(res_element_detector)*1e6:.3f} µm")

# Generate primaries
def generate_primaries(n, max_radius, f):
    positions = []
    golden_angle = pi * (3 - sqrt(mpf('5')))
    for i in range(n):
        r = max_radius * sqrt(mpf(i + 1) / mpf(n))
        theta = golden_angle * i
        x = r * cos(theta)
        y = r * sin(theta)
        z = (x*x + y*y) / (4 * f)

        import random
        z = z + random.random() * 1e-8
        positions.append({'x': x, 'y': y, 'z': z})
    return positions

primaries = generate_primaries(n_primaries, baseline/2, focal_length)

# Print primary positions
print("\nMirror positions:")
for i, p in enumerate(primaries[:5]):
    r = float(sqrt(p['x']**2 + p['y']**2))
    print(f"  {i}: r = {r/1000:.1f} km")


def distance_3d(p1, p2):
    dx = p2['x'] - p1['x']
    dy = p2['y'] - p1['y']
    dz = p2['z'] - p1['z']
    return sqrt(dx*dx + dy*dy + dz*dz)

# On-axis point source at "infinity"
source_distance = mpf('1e19')
source_on_axis = {'x': mpf('0'), 'y': mpf('0'), 'z': source_distance, 'intensity': mpf('1')}

def calculate_field_at_detector(x_det, y_det, source, primaries, wl):
    det = {'x': x_det, 'y': y_det, 'z': focal_length}
    field = mpc('0', '0')
    two_pi_i = mpc('0', '1') * 2 * pi
    for primary in primaries:
        d1 = distance_3d(source, primary)
        d2 = distance_3d(primary, det)
        path = d1 + d2
        phase = two_pi_i * path / wl
        field += 1 / d2 **2 * exp(phase)
    return field

# 1D PSF scan (high resolution)
print("\n--- 1D PSF (high resolution) ---")
n_scan = 2001
scan_range = 1200 * res_element_detector  # ±100 resolution elements

scan_x_res = []
scan_I = []




for i in range(n_scan):
    frac = mpf(i) / mpf(n_scan - 1) - mpf('0.5')
    x = 2 * scan_range * frac
    
    field = calculate_field_at_detector(x, mpf('0'), source_on_axis, primaries, wavelength)
    I = float(fabs(field)**2)
    
    x_res = float(x / res_element_detector)
    scan_x_res.append(x_res)
    scan_I.append(I)

# Find peaks and analyze
scan_I = np.array(scan_I)
scan_x_res = np.array(scan_x_res)

central_peak = scan_I[n_scan//2]
max_sidelobe = np.max(scan_I[np.abs(scan_x_res) > 10])

print(f"Central peak intensity: {central_peak:.1f}")
print(f"Max sidelobe (|x| > 10 res): {max_sidelobe:.3f}")
print(f"Peak/sidelobe ratio: {central_peak/max_sidelobe:.1f}")

# 2D PSF
print("\n--- 2D PSF ---")
n_2d = 51
psf_range = 50 * res_element_detector

grid_x = np.zeros((n_2d, n_2d))
grid_y = np.zeros((n_2d, n_2d))
grid_I = np.zeros((n_2d, n_2d))

for iy in range(n_2d):
    for ix in range(n_2d):
        frac_x = mpf(ix) / mpf(n_2d - 1) - mpf('0.5')
        frac_y = mpf(iy) / mpf(n_2d - 1) - mpf('0.5')
        
        x = 2 * psf_range * frac_x
        y = 2 * psf_range * frac_y
        
        field = calculate_field_at_detector(x, y, source_on_axis, primaries, wavelength)
        I = float(fabs(field)**2)
        
        grid_x[iy, ix] = float(x / res_element_detector)
        grid_y[iy, ix] = float(y / res_element_detector)
        grid_I[iy, ix] = I
    
    if (iy + 1) % 10 == 0:
        print(f"  Row {iy+1}/{n_2d}")

# Plot
fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# 1D PSF (full range)
ax1 = axes[0, 0]
ax1.semilogy(scan_x_res, scan_I, 'b-', linewidth=1)
ax1.axvline(x=0, color='red', linestyle='--', alpha=0.5)
ax1.set_xlabel('Position (resolution elements)')
ax1.set_ylabel('Intensity (log)')
ax1.set_title('1D PSF - Full Range')
ax1.grid(True, alpha=0.3)

# 1D PSF (zoom on center)
ax2 = axes[0, 1]
center_mask = np.abs(scan_x_res) < 20
ax2.plot(scan_x_res[center_mask], scan_I[center_mask], 'b-', linewidth=1.5)
ax2.set_xlabel('Position (resolution elements)')
ax2.set_ylabel('Intensity')
ax2.set_title('1D PSF - Central Region')
ax2.grid(True, alpha=0.3)

# 2D PSF (linear)
ax3 = axes[1, 0]
c3 = ax3.pcolormesh(grid_x, grid_y, grid_I, shading='auto', cmap='hot')
ax3.set_xlabel('x (resolution elements)')
ax3.set_ylabel('y (resolution elements)')
ax3.set_title('2D PSF (linear scale)')
ax3.set_aspect('equal')
plt.colorbar(c3, ax=ax3)

# 2D PSF (log)
ax4 = axes[1, 1]
c4 = ax4.pcolormesh(grid_x, grid_y, np.log10(grid_I + 1e-10), shading='auto', cmap='hot')
ax4.set_xlabel('x (resolution elements)')
ax4.set_ylabel('y (resolution elements)')
ax4.set_title('2D PSF (log scale)')
ax4.set_aspect('equal')
plt.colorbar(c4, ax=ax4, label='log10(I)')

plt.tight_layout()
plt.savefig('/home/claude/jio_psf_analysis.png', dpi=150)
plt.savefig('/mnt/user-data/outputs/jio_psf_analysis.png', dpi=150)
print("\nPSF plot saved.")
```
