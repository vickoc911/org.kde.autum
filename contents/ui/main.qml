/*
    SPDX-FileCopyrightText: 2015 Ivan Safonov <safonov.ivan.s@gmail.com>
    SPDX-FileCopyrightText: 2024 Steve Storey <sstorey@gmail.com>
    SPDX-FileCopyrightText: 2024 Victor Calles <vcalles@gmail.com>

    SPDX-License-Identifier: GPL-3.0-only
*/
import QtQuick
import QtQuick.Particles
import QtQuick3D
import QtQuick3D.Particles3D

import org.kde.plasma.plasmoid

WallpaperItem {
    id: wallpaper
    Image {
        id: root
        anchors.fill: parent

        fillMode: wallpaper.configuration.FillMode
        source: wallpaper.configuration.Image

        readonly property int velocity: wallpaper.configuration.Velocity
        readonly property int numParticles: wallpaper.configuration.Particles
        readonly property int particleSize: wallpaper.configuration.Size
        readonly property int particleLifeSpan: 1.5 * height / velocity

    View3D {
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: "#202020"
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 100, 600)
            clipFar: 2000
        }

        PointLight {
            position: Qt.vector3d(200, 600, 400)
            brightness: 40
            ambientColor: Qt.rgba(0.2, 0.2, 0.2, 1.0)
        }


        ParticleSystem3D {
            id: psystem

            // Start so that the autuming is in full steam
            startTime: 15000

            SpriteParticle3D {
                id: autumParticle
                sprite: Texture {
                    source: wallpaper.configuration.Autumleaf
                }
                maxAmount: 1500 * 5
                color: "#ffffff"
                colorVariation: Qt.vector4d(0.0, 0.0, 0.0, 0.5);
                fadeInDuration: 1000
                fadeOutDuration: 1000
            }

            ParticleEmitter3D {
                id: emitter
                particle: autumParticle
                position: Qt.vector3d(0, 1000, -350)
                depthBias: -100
                scale: Qt.vector3d(15.0, 0.0, 15.0)
                shape: ParticleShape3D {
                    type: ParticleShape3D.Sphere
                }
                particleRotationVariation: Qt.vector3d(180, 180, 180)
                particleRotationVelocityVariation: Qt.vector3d(50, 50, 50);
                particleScale: root.particleSize
                particleScaleVariation: 3.0;
                velocity: VectorDirection3D {
                    direction: Qt.vector3d(0, -100, 0)
                    directionVariation: Qt.vector3d(0, -100 * 0.4, 0)
                }
                emitRate: root.numParticles
                lifeSpan: 15000
            }

            Wander3D {
                enabled: true
                globalAmount: Qt.vector3d(50, 0, 50)
                globalPace: Qt.vector3d(0.20, 0, 0.20)
                uniqueAmount: Qt.vector3d(50, 0, 50)
                uniquePace: Qt.vector3d(0.20, 0, 0.20)
                uniqueAmountVariation: 0.47
                uniquePaceVariation: 0.50
            }
            PointRotator3D {
                enabled: true
                pivotPoint: Qt.vector3d(0, 0, -350)
                direction: Qt.vector3d(0, 1, 0)
                magnitude: 0
            }
        }


}
}
}

