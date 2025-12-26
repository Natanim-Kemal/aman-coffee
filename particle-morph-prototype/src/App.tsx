import { Suspense } from 'react'
import { Canvas } from '@react-three/fiber'
import { ScrollControls, Scroll } from '@react-three/drei'
import { Experience } from './Experience'

function App() {
  return (
    <>
      <Canvas camera={{ position: [0, 0, 8], fov: 35 }}>
        <color attach="background" args={['#1a120b']} />
        <Suspense fallback={null}>
          <ScrollControls pages={3} damping={0.2}>
            {/* The 3D Scene */}
            <Experience />

            {/* The HTML Overlay */}
            <Scroll html style={{ width: '100%' }}>

              {/* SECTION 1: GENESIS (BEAN) */}
              <div className="overlay" style={{ justifyContent: 'flex-start', paddingTop: '15vh' }}>
                <div>
                  <h1 className="title">GENESIS</h1>
                  <p className="subtitle">From the fertile highlands of Ethiopia. The seed of perfection.</p>
                </div>
                <div className="scroll-indicator">Begin the Journey</div>
              </div>

              {/* SECTION 2: AROMA (SPIRAL) */}
              <div className="overlay" style={{ top: '100vh' }}>
                <div style={{ alignSelf: 'flex-end', textAlign: 'right' }}>
                  <h1 className="title">AROMA</h1>
                  <p className="subtitle">The complex dance of roasting. Unlocking the golden essence.</p>
                </div>
              </div>

              {/* SECTION 3: TRADITION (JEBENA) */}
              <div className="overlay" style={{ top: '200vh' }}>
                <div style={{ alignSelf: 'flex-start', textAlign: 'left' }}>
                  <h1 className="title">TRADITION</h1>
                  <p className="subtitle">The Jebena. A ceremony of connection and heritage.</p>
                </div>
              </div>

            </Scroll>

          </ScrollControls>
        </Suspense>
      </Canvas>
    </>
  )
}

export default App
