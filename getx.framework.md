[ UI (View) ]
        ↓
[ Controller (GetX) ]
        ↓
[ Repository ]
        ↓
[ API Client (Dio) ]
        ↓
========= NETWORK =========
        ↓
[ Express Route ]
        ↓
[ Controller (Node) ]
        ↓
[ Service (optional but recommended) ]
        ↓
[ Model (Mongoose) ]
        ↓
[ MongoDB ]
        ↓
========= RESPONSE BACK =========
        ↑
[ Model → Controller → Route ]
        ↑
[ Dio Response ]
        ↑
[ Repository ]
        ↑
[ Controller (.obs update) ]
        ↑
[ UI (Obx rebuild) ]