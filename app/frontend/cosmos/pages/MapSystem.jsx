import React, { useState } from "react";
import MapContainer from "../components/MapSystem/MapContainer";
import LeftPanel from "../components/MapSystem/LeftPanel/LeftPanel";
import PropertyTable from "../components/MapSystem/BottomPanel/PropertyTable";
import MapTest from "../components/MapSystem/MapTest";
import styles from "../styles/MapSystem.module.css";

export default function MapSystem() {
  const [leftPanelPinned, setLeftPanelPinned] = useState(false);
  const [bottomPanelVisible, setBottomPanelVisible] = useState(true);
  const [selectedObject, setSelectedObject] = useState(null);
  const [searchConditions, setSearchConditions] = useState({});
  const [selectedLayers, setSelectedLayers] = useState([]);
  const [showDebugMode, setShowDebugMode] = useState(false);

  const handleMarkerSelect = (type, data) => {
    setSelectedObject({ type, data });
  };

  const handleSearch = (conditions) => {
    setSearchConditions(conditions);
    // ここで地図の表示を更新する処理を追加
    console.log('Search conditions:', conditions);
  };

  const handleLayerToggle = (layerId, enabled) => {
    setSelectedLayers(prev => {
      if (enabled) {
        return [...prev, layerId];
      } else {
        return prev.filter(id => id !== layerId);
      }
    });
    // ここでレイヤーの表示を切り替える処理を追加
    console.log('Layer toggled:', layerId, enabled);
  };

  const handleTogglePin = () => {
    setLeftPanelPinned(!leftPanelPinned);
  };

  // デバッグモード表示
  if (showDebugMode) {
    return (
      <div style={{ padding: '20px' }}>
        <button 
          onClick={() => setShowDebugMode(false)}
          style={{ marginBottom: '20px', padding: '10px', backgroundColor: '#007bff', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          ← 地図システムに戻る
        </button>
        <MapTest />
      </div>
    );
  }

  return (
    <div className={styles.mapSystem}>
      {/* 左ペイン */}
      <LeftPanel
        isPinned={leftPanelPinned}
        onTogglePin={handleTogglePin}
        onSearch={handleSearch}
        onLayerToggle={handleLayerToggle}
        searchConditions={searchConditions}
        selectedLayers={selectedLayers}
      />

      {/* 中央の地図エリア */}
      <MapContainer onMarkerSelect={handleMarkerSelect} />

      {/* 右ペイン */}
      <div className={styles.rightPanel}>
        <div className={styles.rightPanelContent}>
          <h3>物件詳細</h3>
          {selectedObject ? (
            <div className={styles.objectDetails}>
              {selectedObject.type === 'property' && (
                <>
                  <div className={styles.detailItem}>
                    <strong>物件名:</strong>
                    <span>{selectedObject.data.name}</span>
                  </div>
                  <div className={styles.detailItem}>
                    <strong>住所:</strong>
                    <span>{selectedObject.data.address}</span>
                  </div>
                  <div className={styles.detailItem}>
                    <strong>建物種別:</strong>
                    <span>{selectedObject.data.type === 'apartment' ? 'アパート' : 
                           selectedObject.data.type === 'mansion' ? 'マンション' : 
                           selectedObject.data.type === 'house' ? '戸建て' : '不明'}</span>
                  </div>
                  <div className={styles.detailItem}>
                    <strong>総戸数:</strong>
                    <span>{selectedObject.data.rooms}戸</span>
                  </div>
                  <div className={styles.detailItem}>
                    <strong>空室数:</strong>
                    <span>{selectedObject.data.vacantRooms}戸</span>
                  </div>
                  <div className={styles.detailItem}>
                    <strong>空室率:</strong>
                    <span>{((selectedObject.data.vacantRooms / selectedObject.data.rooms) * 100).toFixed(1)}%</span>
                  </div>
                  <div className={styles.detailActions}>
                    <button className={styles.actionButton}>
                      詳細ページを開く
                    </button>
                    <button className={styles.actionButton}>
                      ストリートビュー表示
                    </button>
                  </div>
                </>
              )}
            </div>
          ) : (
            <div className={styles.detailsPlaceholder}>
              <p>地図上の物件を選択してください</p>
            </div>
          )}
        </div>
      </div>

      {/* 下ペイン */}
      {bottomPanelVisible && (
        <div className={styles.bottomPanel}>
          <div className={styles.bottomPanelHeader}>
            <h3>物件一覧</h3>
            <button 
              className={styles.toggleButton}
              onClick={() => setBottomPanelVisible(false)}
            >
              ✕
            </button>
          </div>
          <PropertyTable
            onPropertySelect={(property) => {
              setSelectedObject({ type: 'property', data: property });
            }}
            searchConditions={searchConditions}
          />
        </div>
      )}

      {/* 下ペイン表示ボタン（非表示時） */}
      {!bottomPanelVisible && (
        <button 
          className={styles.showBottomPanelButton}
          onClick={() => setBottomPanelVisible(true)}
        >
          物件一覧を表示
        </button>
      )}
      
      {/* デバッグボタン */}
      <button 
        onClick={() => setShowDebugMode(true)}
        style={{
          position: 'fixed',
          top: '10px',
          right: '10px',
          padding: '8px 12px',
          backgroundColor: '#dc3545',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer',
          fontSize: '12px',
          zIndex: 2000
        }}
      >
        🐛 Debug
      </button>
    </div>
  );
}