import React, { useState } from 'react';
import SearchModal from './SearchModal';
import styles from '../../../styles/MapSystem.module.css';

export default function LeftPanel({ 
  isPinned, 
  onTogglePin, 
  onSearch, 
  onLayerToggle,
  searchConditions = {},
  selectedLayers = []
}) {
  const [isSearchModalOpen, setIsSearchModalOpen] = useState(false);

  // 検索条件の表示用テキストを生成
  const getConditionSummary = () => {
    const conditions = [];
    
    if (searchConditions.propertyName) {
      conditions.push(`物件名: ${searchConditions.propertyName}`);
    }
    if (searchConditions.address) {
      conditions.push(`住所: ${searchConditions.address}`);
    }
    if (searchConditions.buildingType) {
      const typeMap = {
        apartment: 'アパート',
        mansion: 'マンション',
        house: '戸建て',
        other: 'その他'
      };
      conditions.push(`種別: ${typeMap[searchConditions.buildingType]}`);
    }
    if (searchConditions.minRooms || searchConditions.maxRooms) {
      const min = searchConditions.minRooms || '制限なし';
      const max = searchConditions.maxRooms || '制限なし';
      conditions.push(`戸数: ${min}〜${max}戸`);
    }
    if (searchConditions.maxVacancyRate) {
      conditions.push(`空室率: ${searchConditions.maxVacancyRate}%以下`);
    }
    if (searchConditions.minAge || searchConditions.maxAge) {
      const min = searchConditions.minAge || '制限なし';
      const max = searchConditions.maxAge || '制限なし';
      conditions.push(`築年数: ${min}〜${max}年`);
    }

    return conditions.length > 0 ? conditions.join('\n') : '条件なし';
  };

  const availableLayers = [
    { id: 'school-district', label: '学区レイヤー', description: '小中学校の学区境界' },
    { id: 'transport', label: '交通機関レイヤー', description: '駅・バス停・路線' },
    { id: 'commercial', label: '商業施設レイヤー', description: 'ショッピング・飲食店' },
    { id: 'medical', label: '医療機関レイヤー', description: '病院・診療所・薬局' },
    { id: 'parks', label: '公園・緑地レイヤー', description: '公園・緑地・河川' }
  ];

  return (
    <>
      <div 
        className={`${styles.leftPanel} ${isPinned ? styles.pinned : ''}`}
        onMouseEnter={() => !isPinned && setLeftPanelPinned && setLeftPanelPinned(false)}
      >
        <div className={styles.leftPanelContent}>
          <div className={styles.searchSection}>
            <button 
              className={styles.searchButton}
              onClick={() => setIsSearchModalOpen(true)}
            >
              検索条件
            </button>
            <button 
              className={styles.pinButton}
              onClick={onTogglePin}
              title={isPinned ? "固定解除" : "固定"}
            >
              {isPinned ? '📌' : '📍'}
            </button>
          </div>
          
          <div className={styles.currentConditions}>
            <h4>現在の検索条件</h4>
            <div className={styles.conditionsList}>
              <pre className={styles.conditionsText}>{getConditionSummary()}</pre>
            </div>
            {Object.keys(searchConditions).length > 0 && (
              <button 
                className={styles.clearConditionsButton}
                onClick={() => onSearch({})}
              >
                条件をクリア
              </button>
            )}
          </div>
          
          <div className={styles.layerSelector}>
            <h4>レイヤー選択</h4>
            <div className={styles.layerOptions}>
              {availableLayers.map(layer => (
                <div key={layer.id} className={styles.layerOption}>
                  <label>
                    <input 
                      type="checkbox"
                      checked={selectedLayers.includes(layer.id)}
                      onChange={(e) => onLayerToggle(layer.id, e.target.checked)}
                    />
                    <span className={styles.layerLabel}>
                      <strong>{layer.label}</strong>
                      <small>{layer.description}</small>
                    </span>
                  </label>
                </div>
              ))}
            </div>
          </div>

          <div className={styles.quickActions}>
            <h4>クイックアクション</h4>
            <div className={styles.actionButtons}>
              <button 
                className={styles.quickActionButton}
                onClick={() => onSearch({ maxVacancyRate: '10' })}
              >
                空室率10%以下
              </button>
              <button 
                className={styles.quickActionButton}
                onClick={() => onSearch({ buildingType: 'apartment' })}
              >
                アパートのみ
              </button>
              <button 
                className={styles.quickActionButton}
                onClick={() => onSearch({ minRooms: '20' })}
              >
                20戸以上
              </button>
            </div>
          </div>
        </div>
      </div>

      <SearchModal
        isOpen={isSearchModalOpen}
        onClose={() => setIsSearchModalOpen(false)}
        onSearch={onSearch}
        currentConditions={searchConditions}
      />
    </>
  );
}