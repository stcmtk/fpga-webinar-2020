# Материалы к лекции 3 курса "FPGA для начинающих"

В папках исходники Quartus проектов, которые были рассмотрены на лекции.

## Структура папок:

  * debouncer/ -- модуль фильтрации сигнала
    * debouncer/debouncer_tb/ -- тестбенч для debouncer

  * fifo/ -- очередь fifo
    * fifo/fifo_example/ -- Quartus проект fifo
    * fifo/tb/ -- тестбенч для fifo

  * fsm/ -- пример простого конечного автомата
    * fsm/fsm_example/ -- Quartus проект fsm

  * memory/ -- пример памяти
    * memory/memory_example/ -- Quartus проект памяти

  * mux_demux/ -- пример простых мультиплексоров и демультиплексоров
    * mux_demux/mux_example/ -- Quartus проект мультиплексора

  * posedge_detector/ -- выделитель фронта
    * posedge_detector/posedge_detector_example/ -- Quartus проект памяти

## Как собрать проект Quartus

Открыть в Quartus файл <имя_проекта>.qpf

Нажать Start Compilation

## Как запустить симуляцию

  1. Запустите ModelSim
  2. В консоли ModelSim переместитесь в эту папку:
     # cd <путь_до_папки>
  3. Выполните:
     # do make_sim.do
  4. Если временные диаграммы не появились, откройте окно Wave:
     View -> Wave
