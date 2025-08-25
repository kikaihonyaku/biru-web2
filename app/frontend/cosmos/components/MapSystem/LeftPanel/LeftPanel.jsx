import React, { useState } from 'react';
import {
  Box,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Typography,
  Button,
  IconButton,
  FormControlLabel,
  Checkbox,
  Chip,
  Divider,
  TextField,
  Paper,
  Tooltip,
  Fade,
  useMediaQuery,
} from '@mui/material';
import {
  ExpandMore as ExpandMoreIcon,
  PushPin as PushPinIcon,
  PushPinOutlined as PushPinOutlinedIcon,
  Search as SearchIcon,
  Clear as ClearIcon,
  Layers as LayersIcon,
  FilterList as FilterListIcon,
} from '@mui/icons-material';
import SearchModal from './SearchModal';
import muiTheme from '../../../theme/muiTheme';

export default function LeftPanel({ 
  isPinned, 
  onTogglePin, 
  onSearch, 
  onLayerToggle,
  searchConditions = {},
  selectedLayers = [],
  onHoverChange
}) {
  const [isSearchModalOpen, setIsSearchModalOpen] = useState(false);
  const [expanded, setExpanded] = useState({
    conditions: true,
    layers: true,
    quickActions: false,
  });
  const [isHovered, setIsHovered] = useState(false);
  
  // レスポンシブ設定
  const isMdUp = useMediaQuery(muiTheme.breakpoints.up('md'));

  const handleAccordionChange = (panel) => (event, isExpanded) => {
    setExpanded(prev => ({ ...prev, [panel]: isExpanded }));
  };

  // 表示状態を判定（ピン留めされているか、ホバーされているか）
  const isExpanded = isPinned || isHovered;

  // 検索条件をChip形式で取得
  const getConditionChips = () => {
    const chips = [];
    
    if (searchConditions.propertyName) {
      chips.push({ key: 'propertyName', label: `物件名: ${searchConditions.propertyName}` });
    }
    if (searchConditions.address) {
      chips.push({ key: 'address', label: `住所: ${searchConditions.address}` });
    }
    if (searchConditions.buildingType) {
      const typeMap = {
        apartment: 'アパート',
        mansion: 'マンション',
        house: '戸建て',
        other: 'その他'
      };
      chips.push({ key: 'buildingType', label: `種別: ${typeMap[searchConditions.buildingType]}` });
    }
    if (searchConditions.minRooms || searchConditions.maxRooms) {
      const min = searchConditions.minRooms || '制限なし';
      const max = searchConditions.maxRooms || '制限なし';
      chips.push({ key: 'rooms', label: `戸数: ${min}〜${max}戸` });
    }
    if (searchConditions.maxVacancyRate) {
      chips.push({ key: 'maxVacancyRate', label: `空室率: ${searchConditions.maxVacancyRate}%以下` });
    }
    if (searchConditions.minAge || searchConditions.maxAge) {
      const min = searchConditions.minAge || '制限なし';
      const max = searchConditions.maxAge || '制限なし';
      chips.push({ key: 'age', label: `築年数: ${min}〜${max}年` });
    }

    return chips;
  };

  const handleChipDelete = (chipKey) => {
    const newConditions = { ...searchConditions };
    
    switch (chipKey) {
      case 'propertyName':
        delete newConditions.propertyName;
        break;
      case 'address':
        delete newConditions.address;
        break;
      case 'buildingType':
        delete newConditions.buildingType;
        break;
      case 'rooms':
        delete newConditions.minRooms;
        delete newConditions.maxRooms;
        break;
      case 'maxVacancyRate':
        delete newConditions.maxVacancyRate;
        break;
      case 'age':
        delete newConditions.minAge;
        delete newConditions.maxAge;
        break;
    }
    
    onSearch(newConditions);
  };

  const availableLayers = [
    { id: 'school-district', label: '学区レイヤー', description: '小中学校の学区境界' },
    { id: 'transport', label: '交通機関レイヤー', description: '駅・バス停・路線' },
    { id: 'commercial', label: '商業施設レイヤー', description: 'ショッピング・飲食店' },
    { id: 'medical', label: '医療機関レイヤー', description: '病院・診療所・薬局' },
    { id: 'parks', label: '公園・緑地レイヤー', description: '公園・緑地・河川' }
  ];

  const conditionChips = getConditionChips();

  return (
    <>
      <Fade in={true}>
        <Paper
          elevation={2}
          sx={{
            width: isPinned ? 320 : (isHovered ? 320 : 60),
            boxSizing: 'border-box',
            bgcolor: 'primary.main',
            color: 'white',
            overflow: isPinned || isHovered ? 'auto' : 'visible',
            transition: 'width 0.3s ease',
            position: 'absolute',
            top: 0,
            left: 0,
            height: isPinned ? '100vh' : (isHovered ? '100vh' : '220px'),
            zIndex: isPinned ? 1100 : (isHovered ? 1350 : 1300),
            flexShrink: isPinned ? 0 : undefined,
            display: 'flex',
            flexDirection: 'column',
          }}
          onMouseEnter={() => {
            setIsHovered(true);
            onHoverChange && onHoverChange(true);
          }}
          onMouseLeave={() => {
            setIsHovered(false);
            onHoverChange && onHoverChange(false);
          }}
        >
          <Box
            sx={{
              width: 320,
              height: '100%',
              p: isExpanded ? 2 : 0,
              display: 'flex',
              flexDirection: 'column',
              gap: isExpanded ? 2 : 0,
            }}
          >
          {isExpanded ? (
            // 展開時のコンテンツ
            <>
              {/* 検索セクション */}
              <Box sx={{ display: 'flex', gap: 1 }}>
                <Button
                  variant="contained"
                  startIcon={<SearchIcon />}
                  onClick={() => setIsSearchModalOpen(true)}
                  sx={{
                    flex: 1,
                    bgcolor: 'rgba(255, 255, 255, 0.2)',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.3)' },
                  }}
                >
                  検索条件
                </Button>
                <IconButton
                  onClick={onTogglePin}
                  size="small"
                  title={isPinned ? "固定解除" : "固定"}
                  sx={{
                    color: 'white',
                    bgcolor: 'rgba(255, 255, 255, 0.2)',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.3)' },
                  }}
                >
                  {isPinned ? <PushPinIcon /> : <PushPinOutlinedIcon />}
                </IconButton>
              </Box>
            </>
          ) : (
            // 折りたたみ時のアイコンのみ
            <Box
              sx={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: 1,
                pt: 2,
                width: 60,
              }}
            >
              <Tooltip title="検索条件" placement="right">
                <IconButton
                  onClick={() => setIsSearchModalOpen(true)}
                  size="small"
                  sx={{
                    color: 'white',
                    bgcolor: 'rgba(255, 255, 255, 0.2)',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.3)' },
                    mb: 1,
                  }}
                >
                  <SearchIcon />
                </IconButton>
              </Tooltip>
              
              <Tooltip title="レイヤー" placement="right">
                <IconButton
                  size="small"
                  sx={{
                    color: 'white',
                    bgcolor: 'rgba(255, 255, 255, 0.2)',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.3)' },
                    mb: 1,
                  }}
                >
                  <LayersIcon />
                </IconButton>
              </Tooltip>
              
              <Tooltip title="クイックアクション" placement="right">
                <IconButton
                  size="small"
                  sx={{
                    color: 'white',
                    bgcolor: 'rgba(255, 255, 255, 0.2)',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.3)' },
                    mb: 1,
                  }}
                >
                  <FilterListIcon />
                </IconButton>
              </Tooltip>
              
              <Tooltip title={isPinned ? "固定解除" : "固定"} placement="right">
                <IconButton
                  onClick={onTogglePin}
                  size="small"
                  sx={{
                    color: 'white',
                    bgcolor: 'rgba(255, 255, 255, 0.2)',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.3)' },
                  }}
                >
                  {isPinned ? <PushPinIcon /> : <PushPinOutlinedIcon />}
                </IconButton>
              </Tooltip>
            </Box>
          )}

          {isExpanded && (
            <>
              {/* 現在の検索条件 */}
              <Accordion 
                expanded={expanded.conditions} 
                onChange={handleAccordionChange('conditions')}
                disableGutters
              >
            <AccordionSummary expandIcon={<ExpandMoreIcon sx={{ color: 'white' }} />}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                現在の検索条件
              </Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                {conditionChips.length > 0 ? (
                  <>
                    <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                      {conditionChips.map((chip) => (
                        <Chip
                          key={chip.key}
                          label={chip.label}
                          size="small"
                          onDelete={() => handleChipDelete(chip.key)}
                          deleteIcon={<ClearIcon sx={{ color: 'white !important' }} />}
                          sx={{
                            bgcolor: 'rgba(255, 255, 255, 0.2)',
                            color: 'white',
                            fontSize: '0.75rem',
                            '& .MuiChip-deleteIcon': { color: 'white' },
                          }}
                        />
                      ))}
                    </Box>
                    <Button
                      size="small"
                      startIcon={<ClearIcon />}
                      onClick={() => onSearch({})}
                      sx={{
                        alignSelf: 'flex-start',
                        bgcolor: 'rgba(244, 67, 54, 0.8)',
                        color: 'white',
                        '&:hover': { bgcolor: 'rgba(244, 67, 54, 1)' },
                        mt: 1,
                      }}
                    >
                      条件をクリア
                    </Button>
                  </>
                ) : (
                  <Typography variant="body2" sx={{ opacity: 0.8 }}>
                    条件なし
                  </Typography>
                )}
              </Box>
            </AccordionDetails>
          </Accordion>

          {/* レイヤー選択 */}
          <Accordion 
            expanded={expanded.layers} 
            onChange={handleAccordionChange('layers')}
            disableGutters
          >
            <AccordionSummary expandIcon={<ExpandMoreIcon sx={{ color: 'white' }} />}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                レイヤー選択
              </Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                {availableLayers.map(layer => (
                  <FormControlLabel
                    key={layer.id}
                    control={
                      <Checkbox
                        checked={selectedLayers.includes(layer.id)}
                        onChange={(e) => onLayerToggle(layer.id, e.target.checked)}
                        size="small"
                        sx={{ color: 'rgba(255, 255, 255, 0.7)' }}
                      />
                    }
                    label={
                      <Box>
                        <Typography variant="body2" sx={{ fontWeight: 500, lineHeight: 1.2 }}>
                          {layer.label}
                        </Typography>
                        <Typography variant="caption" sx={{ opacity: 0.7, lineHeight: 1.3 }}>
                          {layer.description}
                        </Typography>
                      </Box>
                    }
                    sx={{ 
                      alignItems: 'flex-start',
                      ml: 0,
                      p: 1,
                      borderRadius: 1,
                      '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.1)' },
                    }}
                  />
                ))}
              </Box>
            </AccordionDetails>
          </Accordion>

          {/* クイックアクション */}
          <Accordion 
            expanded={expanded.quickActions} 
            onChange={handleAccordionChange('quickActions')}
            disableGutters
          >
            <AccordionSummary expandIcon={<ExpandMoreIcon sx={{ color: 'white' }} />}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                クイックアクション
              </Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Button
                  size="small"
                  onClick={() => onSearch({ maxVacancyRate: '10' })}
                  sx={{
                    justifyContent: 'flex-start',
                    bgcolor: 'rgba(255, 255, 255, 0.15)',
                    color: 'white',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.25)' },
                  }}
                >
                  空室率10%以下
                </Button>
                <Button
                  size="small"
                  onClick={() => onSearch({ buildingType: 'apartment' })}
                  sx={{
                    justifyContent: 'flex-start',
                    bgcolor: 'rgba(255, 255, 255, 0.15)',
                    color: 'white',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.25)' },
                  }}
                >
                  アパートのみ
                </Button>
                <Button
                  size="small"
                  onClick={() => onSearch({ minRooms: '20' })}
                  sx={{
                    justifyContent: 'flex-start',
                    bgcolor: 'rgba(255, 255, 255, 0.15)',
                    color: 'white',
                    '&:hover': { bgcolor: 'rgba(255, 255, 255, 0.25)' },
                  }}
                >
                  20戸以上
                </Button>
              </Box>
            </AccordionDetails>
          </Accordion>
            </>
          )}
          </Box>
        </Paper>
      </Fade>

      <SearchModal
        isOpen={isSearchModalOpen}
        onClose={() => setIsSearchModalOpen(false)}
        onSearch={onSearch}
        currentConditions={searchConditions}
      />
    </>
  );
}