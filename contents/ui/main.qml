/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.wallpapers.image as Wallpaper
import org.kde.plasma.plasmoid
import QtQuick.Particles
import QtQuick3D
import QtQuick3D.Particles3D

WallpaperItem {
    id: root

    // used by WallpaperInterface for drag and drop
    onOpenUrlRequested: (url) => {
        if (root.pluginName === "org.kde.autum") {
            const result = imageWallpaper.addUsersWallpaper(url);
            if (result.length > 0) {
                // Can be a file or a folder (KPackage)
                root.configuration.Image = result;
            }
        } else {
            imageWallpaper.addSlidePath(url);
            // Save drag and drop result
            root.configuration.SlidePaths = imageWallpaper.slidePaths;
        }
        root.configuration.writeConfig();
    }

    contextualActions: root.pluginName === "org.kde.slideshow" ? [openWallpaperAction, imageWallpaper.nextSlideAction] : []

    PlasmaCore.Action {
        id: openWallpaperAction
        text: i18nd("plasma_wallpaper_org.kde.autum", "Open Wallpaper Image")
        icon.name: "document-open"
        onTriggered: imageView.mediaProxy.openModelImage();
    }

    Connections {
		enabled: root.pluginName === "org.kde.slideshow"
        target: Qt.application
        function onAboutToQuit() {
            root.configuration.writeConfig(); // Save the last position
        }
    }

    Component.onCompleted: {
        // In case plasmashell crashes when the config dialog is opened
        root.configuration.PreviewImage = "null";
        root.loading = true; // delays ksplash until the wallpaper has been loaded
    }

    ImageStackView {
        id: imageView
        anchors.fill: parent

        fillMode: root.configuration.FillMode
        configColor: root.configuration.Color
        blur: root.configuration.Blur
        source: {
            if (root.pluginName === "org.kde.slideshow") {
                return imageWallpaper.image;
            }
            if (root.configuration.PreviewImage !== "null") {
                return root.configuration.PreviewImage;
            }
            return root.configuration.Image;
        }
        sourceSize: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)
        wallpaperInterface: root

        Wallpaper.ImageBackend {
            id: imageWallpaper

            // Not using root.configuration.Image to avoid binding loop warnings
            configMap: root.configuration
            usedInConfig: false
            //the oneliner of difference between image and slideshow wallpapers
            renderingMode: (root.pluginName === "org.kde.autum") ? Wallpaper.ImageBackend.SingleImage : Wallpaper.ImageBackend.SlideShow
            targetSize: imageView.sourceSize
            slidePaths: root.configuration.SlidePaths
            slideTimer: root.configuration.SlideInterval
            slideshowMode: root.configuration.SlideshowMode
            slideshowFoldersFirst: root.configuration.SlideshowFoldersFirst
            uncheckedSlides: root.configuration.UncheckedSlides

            // Invoked from C++
            function writeImageConfig(newImage: string) {
                configMap.Image = newImage;
            }
        }

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
                        source: root.configuration.Autumleaf
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
                    particleScale: root.configuration.Size
                    particleScaleVariation: 3.0;
                    velocity: VectorDirection3D {
                        direction: Qt.vector3d(0, -100, 0)
                        directionVariation: Qt.vector3d(0, -100 * 0.4, 0)
                    }
                    emitRate: root.configuration.Particles
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

    Component.onDestruction: {
        if (root.pluginName === "org.kde.slideshow") {
            root.configuration.writeConfig(); // Save the last position
        }
    }
}
