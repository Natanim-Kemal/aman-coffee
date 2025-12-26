import { useRef, useMemo } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import * as THREE from 'three'
import { useScroll } from '@react-three/drei'

// Modern coffee particle shader
const vertexShader = `
  uniform float uProgress;
  uniform float uTime;
  attribute vec3 aPositionTarget1;
  attribute vec3 aPositionTarget2;
  attribute float aSize;
  
  void main() {
    float t = uProgress;
    
    vec3 mixedPosition;
    
    // First transition: Bean (0) to Spiral (1)
    if (t <= 1.0) {
        float ease = t * t * (3.0 - 2.0 * t); // Smooth easing
        mixedPosition = mix(position, aPositionTarget1, ease);
        
        // Add wavering effect (Heat)
        mixedPosition.x += sin(mixedPosition.y * 2.0 + uTime) * 0.05 * ease; 
        mixedPosition.z += cos(mixedPosition.y * 2.0 + uTime) * 0.05 * ease;
    } 
    // Second transition: Spiral (1) to Jebena (2)
    else {
        float p = t - 1.0;
        float ease = p * p * (3.0 - 2.0 * p);
        mixedPosition = mix(aPositionTarget1, aPositionTarget2, ease);
        
        // Add subtle breathing to the Jebena
        if (p > 0.8) {
            float breath = sin(uTime * 2.0) * 0.02;
            mixedPosition += normalize(mixedPosition) * breath;
        }
        
        // Add wavering to spiral fading out
        if (p < 0.5) {
             mixedPosition.x += sin(mixedPosition.y * 2.0 + uTime) * 0.05 * (1.0 - p * 2.0); 
        }
    }
    
    vec4 mvPosition = modelViewMatrix * vec4(mixedPosition, 1.0);
    gl_Position = projectionMatrix * mvPosition;
    
    // Size attenuation
    gl_PointSize = aSize * (40.0 / -mvPosition.z);
  }
`

const fragmentShader = `
  void main() {
    float d = distance(gl_PointCoord, vec2(0.5));
    if (d > 0.5) discard;
    
    // Soft particle edge
    float alpha = 1.0 - smoothstep(0.0, 0.5, d);
    
    // Coffee/Gold colors
    // R: 1.0, G: 0.7, B: 0.3 (Golden) -> slightly darker/redder for coffee
    vec3 color = vec3(1.0, 0.75, 0.4); 
    
    gl_FragColor = vec4(color, alpha);
  }
`

export const Experience = () => {
  const mesh = useRef<THREE.Points>(null!)
  const material = useRef<THREE.ShaderMaterial>(null!)
  const scroll = useScroll()

  const count = 8000

  const [positions, targets1, targets2, sizes] = useMemo(() => {
    const positions = new Float32Array(count * 3) // Bean
    const targets1 = new Float32Array(count * 3)  // Spiral
    const targets2 = new Float32Array(count * 3)  // Jebena
    const sizes = new Float32Array(count)

    // SHAPE 1: COFFEE BEAN (Positions)
    for (let i = 0; i < count; i++) {
      const theta = Math.random() * Math.PI * 2
      const phi = Math.acos(2 * Math.random() - 1)

      // Elongated Sphere
      let r = 1.8 + Math.random() * 0.2
      let x = r * Math.sin(phi) * Math.cos(theta)
      let y = r * Math.sin(phi) * Math.sin(theta) * 1.5 // Elongate Y
      let z = r * Math.cos(phi) * 0.8 // Flatten Z

      // The "Crease" (Split the bean)
      // If x is positive, move it slightly right. If negative, move left.
      // But drag center points inwards to form the cut.
      const zDist = Math.abs(z);
      if (x > 0) x += 0.2;
      else x -= 0.2;

      // Pinch the center
      z *= 1.0 - (1.0 - Math.abs(x) / 2.5) * 0.3;

      positions[i * 3] = x
      positions[i * 3 + 1] = y
      positions[i * 3 + 2] = z

      sizes[i] = Math.random()
    }

    // SHAPE 2: AROMA / SPIRAL (Targets 1)
    for (let i = 0; i < count; i++) {
      const t = (i / count) * Math.PI * 12
      const radius = 0.5 + (i / count) * 2.5 // Expanding radius

      const x = Math.cos(t) * radius + (Math.random() - 0.5) * 0.5
      const y = (i / count) * 10 - 5 // Rising up
      const z = Math.sin(t) * radius + (Math.random() - 0.5) * 0.5

      targets1[i * 3] = x
      targets1[i * 3 + 1] = y
      targets1[i * 3 + 2] = z
    }

    // SHAPE 3: ETHIOPIAN JEBENA (Targets 2)
    // Modeled by parts
    let i = 0;

    // 1. Base Bulb (Sphere) (~55%)
    const bodyCount = Math.floor(count * 0.55);
    for (; i < bodyCount; i++) {
      const theta = Math.random() * Math.PI * 2
      const phi = Math.acos(2 * Math.random() - 1)
      const r = 2.0;

      targets2[i * 3] = r * Math.sin(phi) * Math.cos(theta)
      targets2[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta) - 1.5 // Move down
      targets2[i * 3 + 2] = r * Math.cos(phi)
    }

    // 2. Neck (Cylinder) (~20%)
    const neckCount = i + Math.floor(count * 0.2);
    for (; i < neckCount; i++) {
      const theta = Math.random() * Math.PI * 2
      const h = Math.random() * 2.5 // Height
      const r = 0.6 // Neck radius

      targets2[i * 3] = r * Math.cos(theta)
      targets2[i * 3 + 1] = h + 0.0 // Start from top of sphere roughly
      targets2[i * 3 + 2] = r * Math.sin(theta)
    }

    // 3. Spout (Angled Cylinder/Cone) (~15%)
    const spoutCount = i + Math.floor(count * 0.15);
    for (; i < spoutCount; i++) {
      const u = Math.random() // length along spout
      const theta = Math.random() * Math.PI * 2

      // Spout vector direction (up and left)
      // Start at y=-0.5, x=-1.5
      const len = u * 2.5
      const r = 0.2 + u * 0.1 // Slight flare

      // Base position on spout line
      const bx = -1.0 - len * 0.8
      const by = -0.5 + len * 0.8
      const bz = 0.0

      targets2[i * 3] = bx + r * Math.cos(theta)
      targets2[i * 3 + 1] = by + r * Math.sin(theta)
      targets2[i * 3 + 2] = bz + r * Math.sin(theta) * 0.5
    }

    // 4. Handle (Arc/Torus Segment) (Remainder)
    for (; i < count; i++) {
      const u = Math.random() * Math.PI // Half circle
      const rMajor = 1.8
      const rMinor = 0.15 // Thickness
      const theta = Math.random() * Math.PI * 2

      // Circle centered at x=1.5, y=0
      const cx = 1.0 + rMajor * Math.sin(u * 0.8)
      const cy = 0.0 + rMajor * Math.cos(u * 0.8)
      const cz = 0.0

      targets2[i * 3] = cx + rMinor * Math.cos(theta)
      targets2[i * 3 + 1] = cy + rMinor * Math.sin(theta)
      targets2[i * 3 + 2] = cz + rMinor * Math.sin(theta)
    }

    return [positions, targets1, targets2, sizes]
  }, [])

  const uniforms = useMemo(() => ({
    uProgress: { value: 0 },
    uTime: { value: 0 }
  }), [])

  useFrame((state) => {
    const offset = scroll.offset // 0 to 1

    if (material.current) {
      // Map scroll (0..1) to uProgress (0..2)
      // With physics dampening
      // We want 0-0.5 scroll to be 0-1 progress
      // And 0.5-1.0 scroll to be 1-2 progress
      const targetProgress = offset * 2.0;

      material.current.uniforms.uProgress.value = THREE.MathUtils.lerp(
        material.current.uniforms.uProgress.value,
        targetProgress,
        0.05
      )
      material.current.uniforms.uTime.value = state.clock.getElapsedTime()
    }

    if (mesh.current) {
      // Slow rotation makes it look premium
      mesh.current.rotation.y = -state.clock.getElapsedTime() * 0.1
    }
  })

  return (
    <points ref={mesh} rotation-z={0.26}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          args={[positions, 3]}
        />
        <bufferAttribute
          attach="attributes-aPositionTarget1"
          args={[targets1, 3]}
        />
        <bufferAttribute
          attach="attributes-aPositionTarget2"
          args={[targets2, 3]}
        />
        <bufferAttribute
          attach="attributes-aSize"
          args={[sizes, 1]}
        />
      </bufferGeometry>
      <shaderMaterial
        ref={material}
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        uniforms={uniforms}
        transparent
        depthWrite={false}
        blending={THREE.AdditiveBlending}
      />
    </points>
  )
}
