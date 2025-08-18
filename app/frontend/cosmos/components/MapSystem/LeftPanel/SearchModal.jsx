import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import styles from './SearchModal.module.css';

export default function SearchModal({ isOpen, onClose, onSearch, currentConditions = {} }) {
  const [searchForm, setSearchForm] = useState({
    propertyName: '',
    address: '',
    buildingType: '',
    managementType: '',
    minRooms: '',
    maxRooms: '',
    maxVacancyRate: '',
    minAge: '',
    maxAge: ''
  });

  // モーダルが開かれた時に現在の条件を設定
  useEffect(() => {
    if (isOpen) {
      setSearchForm({
        propertyName: currentConditions.propertyName || '',
        address: currentConditions.address || '',
        buildingType: currentConditions.buildingType || '',
        managementType: currentConditions.managementType || '',
        minRooms: currentConditions.minRooms || '',
        maxRooms: currentConditions.maxRooms || '',
        maxVacancyRate: currentConditions.maxVacancyRate || '',
        minAge: currentConditions.minAge || '',
        maxAge: currentConditions.maxAge || ''
      });
    }
  }, [isOpen, currentConditions]);

  const handleInputChange = (field, value) => {
    setSearchForm(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSearch = (e) => {
    e.preventDefault();
    onSearch(searchForm);
    onClose();
  };

  const handleReset = () => {
    setSearchForm({
      propertyName: '',
      address: '',
      buildingType: '',
      managementType: '',
      minRooms: '',
      maxRooms: '',
      maxVacancyRate: '',
      minAge: '',
      maxAge: ''
    });
    onSearch({});
    onClose();
  };

  // ESCキーでモーダルを閉じる
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = 'unset';
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return createPortal(
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.modalContent} onClick={(e) => e.stopPropagation()}>
        <div className={styles.modalHeader}>
          <h2>検索条件設定</h2>
          <button className={styles.closeButton} onClick={onClose}>✕</button>
        </div>

        <form className={styles.searchForm} onSubmit={handleSearch}>
          <div className={styles.formGrid}>
            <div className={styles.formGroup}>
              <label>物件名</label>
              <input
                type="text"
                placeholder="物件名を入力"
                value={searchForm.propertyName}
                onChange={(e) => handleInputChange('propertyName', e.target.value)}
              />
            </div>

            <div className={styles.formGroup}>
              <label>住所</label>
              <input
                type="text"
                placeholder="住所を入力"
                value={searchForm.address}
                onChange={(e) => handleInputChange('address', e.target.value)}
              />
            </div>

            <div className={styles.formGroup}>
              <label>建物種別</label>
              <select
                value={searchForm.buildingType}
                onChange={(e) => handleInputChange('buildingType', e.target.value)}
              >
                <option value="">選択してください</option>
                <option value="apartment">アパート</option>
                <option value="mansion">マンション</option>
                <option value="house">戸建て</option>
                <option value="other">その他</option>
              </select>
            </div>

            <div className={styles.formGroup}>
              <label>管理方式</label>
              <select
                value={searchForm.managementType}
                onChange={(e) => handleInputChange('managementType', e.target.value)}
              >
                <option value="">選択してください</option>
                <option value="full">一括管理</option>
                <option value="partial">一部管理</option>
                <option value="none">管理なし</option>
              </select>
            </div>

            <div className={styles.formGroup}>
              <label>戸数（最小）</label>
              <input
                type="number"
                placeholder="最小戸数"
                min="1"
                value={searchForm.minRooms}
                onChange={(e) => handleInputChange('minRooms', e.target.value)}
              />
            </div>

            <div className={styles.formGroup}>
              <label>戸数（最大）</label>
              <input
                type="number"
                placeholder="最大戸数"
                min="1"
                value={searchForm.maxRooms}
                onChange={(e) => handleInputChange('maxRooms', e.target.value)}
              />
            </div>

            <div className={styles.formGroup}>
              <label>空室率（最大%）</label>
              <input
                type="number"
                placeholder="最大空室率"
                min="0"
                max="100"
                value={searchForm.maxVacancyRate}
                onChange={(e) => handleInputChange('maxVacancyRate', e.target.value)}
              />
            </div>

            <div className={styles.formGroup}>
              <label>築年数（最小年）</label>
              <input
                type="number"
                placeholder="最小築年数"
                min="0"
                value={searchForm.minAge}
                onChange={(e) => handleInputChange('minAge', e.target.value)}
              />
            </div>

            <div className={styles.formGroup}>
              <label>築年数（最大年）</label>
              <input
                type="number"
                placeholder="最大築年数"
                min="0"
                value={searchForm.maxAge}
                onChange={(e) => handleInputChange('maxAge', e.target.value)}
              />
            </div>
          </div>

          <div className={styles.buttonGroup}>
            <button type="button" className={styles.resetButton} onClick={handleReset}>
              条件をクリア
            </button>
            <button type="submit" className={styles.searchButton}>
              検索実行
            </button>
          </div>
        </form>
      </div>
    </div>,
    document.body
  );
}