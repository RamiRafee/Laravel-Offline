import './bootstrap';
import '../css/app.css';
import GLOBE  from 'vanta/dist/vanta.globe.min';
import * as THREE from 'three';
import List from 'list.js';

window.THREE = THREE;
window.VANTA = { GLOBE }; // Access via VANTA.GLOBE
window.List = List;

document.addEventListener('DOMContentLoaded', () => {
    // Initialize Vanta Globe Background
    window.VANTA.GLOBE({
        el: "#globe-background",
        THREE: window.THREE,
        mouseControls: true,
        touchControls: true,
        minHeight: 400.00,
        minWidth: 400.00,
        scale: 1.00,
        scaleMobile: 1.00,
        color: 0xff0000,
        backgroundColor: 0x111111
    });
    window.VANTA.GLOBE({
        el: "#vanta-bg",
        THREE: window.THREE,
        color: 0x111111,
        backgroundColor: 0x00c3ff,
    });
    // Initialize List.js for sorting/search
    const options = {
        valueNames: ['task-title', 'task-status']
    };
    new List('task-list', options);
});
